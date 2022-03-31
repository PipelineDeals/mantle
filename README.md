# Mantle

[![Circle CI](https://circleci.com/gh/PipelineDeals/mantle.svg?style=svg)](https://circleci.com/gh/PipelineDeals/mantle)
[![Code Climate](https://codeclimate.com/github/PipelineDeals/mantle/badges/gpa.svg)](https://codeclimate.com/github/PipelineDeals/mantle)

To learn more about Mantle and it's internal, see [this slide
deck](https://speakerdeck.com/brandonhilkert/a-path-to-services?slide=57).

## Installation

Add this line to your application's Gemfile:

    gem 'mantle'

or install manually by:

    $ gem install mantle


## Usage (in Rails App)

### Configure

Setup a Rails initializer(`config/initializers/mantle.rb`):


```Ruby
Mantle.configure do |config|
  config.message_bus_redis = Redis.new(host: ENV["MESSAGE_BUS_REDIS_URL"] || 'localhost')
  config.message_handlers = {
    'account:update' => 'MyMessageHandler',
    'order' => ['MyMessageHandler', 'MyOtherMessageHandler']
  }
end
```

The config takes a number of options, many of which have defaults:

```Ruby
Mantle.configure do |config|
  config.message_bus_redis = Redis.new(host: 'localhost') # default: localhost
  config.logger = Rails.logger # default: Logger.new(STDOUT)
  config.redis_namespace = "my-namespace" # default: no namespace
  config.message_handlers = {'deal:update' => 'MyHandler'} # default: {}
end
```

To make the installation of mantle easier, the following command will create
these files in a Rails application:

```
$ rails g mantle:install
```

If an application only pushes messages on to the queue and doesn't listen, the
following configuration is all that's needed:

```Ruby
Mantle.configure do |config|
  config.message_bus_redis = Redis.new(host: 'localhost') # default: localhost
  config.logger = Rails.logger # default: Logger.new(STDOUT)
end
```

### Publish Messages (Publisher)

Publish messages to consumers:

```Ruby
Mantle::Message.new("person:create").publish(message: { id: message['id'], data: message['data'] })
```

The first and only argument to `Mantle::Message.new` is the channel you want to publish the
message on. The `#publish` method takes a named argument `message:` which contains the message content (in any structure you like).
This pushes the `message` on to the message bus pub/sub and also adds it to the
catch up queue so offline applications can process the message when they become available.

Note that you can still use a bare argument for the message, but this will be deprecated in the future:

```Ruby
Mantle::Message.new("person:create").publish({ id: message['id'], data: message['data'] })
```

### Receive Messages (Consumer)

Define message handler class with `.receive` method. For example `app/models/my_message_handler.rb`

```Ruby
class MyMessageHandler
  def self.receive(channel:, message:)
    puts channel # => 'order'
    puts message # => { 'id' => 5, 'name' => 'Brandon' }
  end
end
```

Note that you can still use two bare arguments for the channel and message, but this will be deprecated in the future:

```Ruby
class MyMessageHandler
  def self.receive(channel, message)
    puts channel # => 'order'
    puts message # => { 'id' => 5, 'name' => 'Brandon' }
  end
end
```


### Listener / Processor

To run the listener:

```
$ bin/mantle
```

or with configuration:

```
$ bin/mantle -c ./config/initializers/other_file.rb
```

To run the processor:

```
$ bin/sidekiq -q mantle
```

If the Sidekiq worker should also listen on another queue, add that to the
command with:

```
$ bin/sidekiq -q mantle -q default
```

It will NOT add the `default` queue to processing if there are other queues
enumerated using the `-q` option.

### Large Payloads

Because Mantle uses Redis for the message bus, sending very large messages can quickly use a lot of Redis store,
and in the event that Redis memory is exceeded, your app will be rendered inoperable. In addition, a Mantle handle may
need to pass the `message` on to other services (for example, queue processors), passing very large messages can
compound resulting in even greater memory usage for the same exact payload.

For this reason, it sometimes makes sense to send large payloads through an external key/value store where the handler can
retrieve the payload only when needed instead of pass the entire payload as part of the message.

Note that rather than move the entire payload to external store, it often makes sense for the handler to have a small amount
of data available without retrieving the external payload, such as `account_id` so the handler can do something like this in
the top of the handler (this reveals a named argument `uuid` which is documented below):

```Ruby
class MyMessageHandler
  def self.receive(channel:, message:, uuid:)
    return unless interesting_account?(message['account_id'])

    puts channel # => 'order'
    puts message # => { 'id' => 5, 'name' => 'Brandon' }
  end
end
```

#### Configuring External Store

Mantle facilitates sending large payloads with limited impact on your message bus memory usage by allowing you to
configure an external store by adding the following in the initializer.

External store can use either `redis` (optionally, a different `Redis` instance) or `ActiveRecord`.

To use `redis` use a hash to configure an `external_store_manager`:

``` Ruby
Mantle.configure do |config|
  ...
  config.external_store_manager = { redis: Redis.new(host: 'localhost'), keep_for: 3.hours } # default: keep_for: nil
  ...
end
```

To use `ActiveRecord` use a hash to configure an `external_store_manager`:

``` Ruby
Mantle.configure do |config|
  ...
  config.external_store_manager = { table_name: `my_external_payloads`, database: {...}, keep_for: 3.hours } # default: keep_for: nil
  ...
end
```

The `database` hash will be passed to ActiveRecord `establish_connection`.

The `table_name` specified must be a table in the database, and must be creating using the following migration:

```Ruby
  create_table :my_external_payloads do |t|
    t.string :uuid, nil: false
    t.text :payload, nil: false
    t.timestamp :keep_until, nil: true
    t.timestamp :expire_at, nil: true
    t.timestamp :created_at, nil: false
  end

  add_index :my_external_payloads, :uuid
  add_index :my_external_payloads, :expire_at
  add_index :my_external_payloads, :created_at
```

#### Publishing with External Payloads

An external payload can added to the publish method as using a named argument, `payload:`:

```Ruby
the_payload = { body: 'large_external_payload' }
the_message = { id: message['id'], data: message['data'] }
Mantle::Message.new("person:create").publish(payload: the_payload, message: the_message)
```

There are three ways the `ExternalStoreManager` will free memory.
- If a `keep_until` parameter is specified, then the payload will not be freed until that time. The payload may outlive the specified time, based on `least recently created`.
- If an `expire_at` parameter is specified, then the payload will be freed at that time. The payload will not outlive the specified time.
- If neither qualifier is specified by the publisher, then `least recently created` will be freed, as needed.

```Ruby
Mantle::Message.new("person:create").publish(message: { id: message['id'], data: message['data'] }, payload: { body: 'large_external_payload' }, keep_until: 3.hours.from_now)

Mantle::Message.new("person:create").publish(message: { id: message['id'], data: message['data'] }, payload: { body: 'large_external_payload' }, expire_at: 3.hours.from_now)
```

#### Retrieving External Payloads

A handler (consumer) does not need to be aware there is an external payload. If it does not define a named argument `uuid`,
then the Mantle processor will retrieve the payload and merge it into the message before calling the handler.

If, however, the handler is aware of the extneral payload, then it simply defineds a named argument `uuid` in the method, and
the `uuid` will be set, and the `payload` will not be merged into message.

```Ruby
class MyMessageHandler
  def self.receive(channel:, message:, uuid:)
    puts channel # => 'order'
    puts message # => { 'id' => 5, 'name' => 'Brandon' }
    puts external_store_uuid # => ''
    puts Mantle.retrieve_external_payload(uuid) # => { 'body' => 'large_external_payload' }
  end
end
```

One may want to keep the payload separate from the message so that the handler can pass the `uuid` as a parameter to a queue processor. This would avoid
always adding large payloads to Sidekiq parameters (for example). In this case, the sidekiq processor would also need to be aware of the `uuid` and can call

```Reuby
   Mantle.external_store_managers.retrieve(uuid: uuid)
```

#### Using External Store Directly

Using the concept of avoiding sending large payloads to queue processors may make senese even outside of Mantle handlers.

For this reason, the `external_store_manager` is available to be used outside of Mantle:

```Reuby
   uuid = Mantle.external_store_managers.store(payload: "my large payload")
```

and then within the processor:


```Reuby
   Mantle.external_store_managers.retrieve(uuid: uuid)
```

## Testing

Requiring this library causes messages to be appended to an in-memory array.

```Ruby
# test/test_helper.rb
require 'mantle/testing'
```

```Ruby
class OrderMessage
  def perform(message)
    Mantle::Message.new("order:create").publish(message)
  end
end
```

```Ruby
class OrderMessageTest < ActiveSupport::TestCase
  test "sends a mantle message on created order" do
    OrderMessage.new.perform(mantle_message)
    assert_equal 1, Mantle.messages.size

    msg = Mantle.messages.first
    assert_equal "order:create", msg.channel
    assert_equal mantle_message, msg.message
  end

  private

  def mantle_message
    { id: 5 }
  end
end
```

Be sure to clear out messages so they don't build up during the test suite:

```Ruby
def teardown
  Mantle.clear_all
end
```

## Publishing

To publish a new version of this gem:

* Branch off of `master`, commit your changes to this branch (incrementing the `VERSION` constant)
* Merge branch into `master`
* Checkout `master` locally and run:

```
rake build
gem push pkg/mantle-<new version number>.gem
```

You will be asked for email address and password credentials for `rubygems.org` - use the `engineering@pipelinedeals.com` credentials

All done! You should see the new version here: https://rubygems.org/gems/mantle

To cut a new github release for this version, click `New Release` from this repo's `Releases` tab.

