# AGENTS.md — mantle

Context file for AI agents and new developers. Verify against the code before
relying on it; flag anything stale in a PR.

## What this is

Mantle is Pipeline CRM's internal message bus gem, published to rubygems.org
as `mantle` (current version: `lib/mantle/version.rb`). It lets our Rails apps
publish domain events (e.g. `person:create`, `deal:update`) over a shared
Redis pub/sub connection, and lets consuming apps handle those events via
Sidekiq jobs. A Redis sorted set ("catch up" queue) buffers recent messages so
a consumer that was offline can replay what it missed on startup.

Background on the design: https://speakerdeck.com/brandonhilkert/a-path-to-services (slide 57+).

## Setup / test / release

Ruby: CI runs `cimg/ruby:3.1.3`. Bundler: 2.4.5 (`BUNDLED_WITH` in Gemfile.lock).

```sh
gem install bundler:2.4.5
bundle install
bundle exec rspec          # full suite; CI runs the same via spec/**/*_spec.rb glob
```

- CI is CircleCI (`.circleci/config.yml`): bundle install, then
  `bundle exec rspec --format progress --format RspecJunitFormatter --out test_results/rspec.xml`.
- **Specs need a real local Redis on localhost:6379.** `spec/spec_helper.rb`
  points `message_bus_redis` at `localhost` db 9 and writes marker keys through
  `Sidekiq.redis` (default db 0). Don't run the suite against a Redis you care
  about. CI provides this with a `redis` Docker sidecar.
- There is no linter (no RuboCop config) and no Rakefile test task —
  `Rakefile` only loads `bundler/gem_tasks` (build/install/release tasks).

Releasing a new version (from README):
1. Branch off `master`, bump `Mantle::VERSION` in `lib/mantle/version.rb`,
   update `CHANGELOG.md`, merge to `master`.
2. On `master`: `rake build` then `gem push pkg/mantle-<version>.gem`
   (rubygems.org credentials: `engineering@pipelinedeals.com`).
3. Cut a GitHub release for the tag.

## Architecture

```
lib/mantle.rb                  Module root: Mantle.configure, receive_message, channels
lib/mantle/
  configuration.rb             message_bus_redis, logger, redis_namespace, whoami, message_handlers
  message.rb                   Publish API: Mantle::Message.new(channel).publish(payload)
  message_bus.rb               Redis pub/sub publish + blocking subscribe loop
  catch_up.rb                  Sorted set "mantle:catch_up" on the message-bus Redis
  message_router.rb            Wraps enqueue of ProcessWorker, logs enqueue failures
  message_handlers.rb          channel => handler-class-name(s) map (SimpleDelegator over Hash)
  message_handler.rb           Abstract base; implement self.receive(channel, message)
  local_redis.rb               Per-app pointer keys, stored via Sidekiq.redis
  workers/                     Sidekiq workers, all on queue :mantle
    process_worker.rb          Fans message out to handlers, records success time
    message_handler_worker.rb  const_gets handler class and calls .receive
    catch_up_cleanup_worker.rb Trims catch-up entries older than 1 hour
  cli.rb                       bin/mantle option parsing + Sidekiq redis namespace config
  testing.rb                   Test shim: publish appends to in-memory Mantle.messages
  railtie.rb                   No-op Railtie (loaded when Rails is defined)
lib/generators/mantle/install/ `rails g mantle:install` — writes initializer + example handler
bin/mantle                     Listener process entry point
config.ru                      Mounts Sidekiq::Web (rack app for inspecting the mantle queue)
spec/                          RSpec suite mirroring lib/
```

### Message flow

Publish side (any app):
`Mantle::Message#publish` merges `__MANTLE__: {message_source: whoami}` into
the payload (when `whoami` is configured), then (1) `PUBLISH`es JSON on the
channel and (2) `ZADD`s it to `mantle:catch_up` scored by current UTC time.
Both hit the shared `message_bus_redis`.

Consume side (apps with `message_handlers` configured):
1. `bin/mantle` runs a long-lived listener: on boot it replays the catch-up
   queue, then blocks in `redis.subscribe(Mantle.channels)`.
2. Each received message enqueues `Workers::ProcessWorker` (Sidekiq queue
   `mantle` — so a Sidekiq process must run `-q mantle`).
3. `ProcessWorker` enqueues one `MessageHandlerWorker` per configured handler
   for the channel, sets `last_successful_message_received` (in the app's own
   Sidekiq Redis), and enqueues cleanup if the last cleanup was >5 min ago.

Catch-up replay: on listener boot, `CatchUp#catch_up` reads
`ZRANGEBYSCORE mantle:catch_up <last_success_time> inf` and routes entries
whose channel this app subscribes to. If the app has never successfully
processed a message (`last_success_time` nil), replay is skipped entirely.

### Two Redis connections — don't conflate them

- `message_bus_redis` (config): shared across all apps; carries pub/sub and
  the `mantle:catch_up` sorted set.
- `Sidekiq.redis` (per app): carries the job queue plus the pointer keys
  `last_successful_message_received` and `mantle:catch_up:cleanup`
  (see `local_redis.rb`). These keys are top-level and unnamespaced.

## Usage in an app (short version — full examples in README.md)

```ruby
# config/initializers/mantle.rb
Mantle.configure do |config|
  config.message_bus_redis = Redis.new(host: ENV["MESSAGE_BUS_REDIS_URL"] || "localhost")
  config.message_handlers  = { "deal:update" => "MyHandler" }  # omit if publish-only
end
```

- Run the listener: `bin/mantle` (or `bin/mantle -c path/to/initializer.rb`;
  default config path is `./config/initializers/mantle`).
- Run the processor: `bin/sidekiq -q mantle` (add `-q default` etc. as needed).
- Handlers are class names as strings; the class must respond to
  `self.receive(channel, message)`.
- In tests, `require "mantle/testing"` replaces publishing with an in-memory
  `Mantle.messages` array; call `Mantle.clear_all` in teardown.

## Pitfalls (all verified in code)

- **Sidekiq is pinned `< 7.0`** (gemspec; lockfile resolves 6.5.12). The CLI's
  `redis_namespace` support uses the `namespace:` option that Sidekiq 7
  removed, and workers use the classic `Sidekiq::Worker` include. Don't bump
  the pin casually — consumers' Gemfiles resolve against it.
- **redis gem is 4.x** in the lockfile; `MessageBus#subscribe_to_channels`
  passes an Array to `redis.subscribe` — check this API before a redis 5.x
  upgrade.
- **Catch-up window is 1 hour** (`CatchUp::HOURS_TO_KEEP`), trimmed by
  `CatchUpCleanupWorker` at most every 5 minutes. A consumer down longer than
  an hour silently loses messages; there is no dead-letter store.
- **Catch-up replay can double-deliver**: replay starts from the last success
  time inclusive, and handlers get everything since — handlers must be
  idempotent.
- **`MessageRouter#route` swallows enqueue exceptions** (logs and drops the
  message). If Sidekiq's Redis is down when a message arrives, that message is
  only recoverable via catch-up replay.
- **`mantle/testing` must be required after `mantle`** and redefines
  `Mantle::Message#publish` globally for the process — never load it in
  production code paths.
- The channel-to-handler map (`message_handlers=`) replaces the whole
  `MessageHandlers` object; there's no merge API.

## Key docs

- `README.md` — full install/usage/testing/publishing walkthrough.
- `CHANGELOG.md` — version history (update it when bumping VERSION).
