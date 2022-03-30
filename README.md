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
Mantle::Message.new("person:create").publish({ id: message['id'], data: message['data'] })
```

The first and only argument to `Mantle::Message.new` is the channel you want to publish the
message on. The `#publish` method takes the message payload (in any format you like)
and pushes the message on to the message bus pub/sub and also adds it to the
catch up queue so offline applications can process the message when they become available.

### Receive Messages (Listeners)

Define message handler class with `.receive` method. For example `app/models/my_message_handler.rb`

```Ruby
class MyMessageHandler
  def self.receive(channel, message)
    puts channel # => 'order'
    puts message # => { 'id' => 5, 'name' => 'Brandon' }
  end
end
```

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
compound in even greater memory usage.

For this reason, it sometimes makes sense to send large payloads through an external key/value store where the handler can
pull in the payload.

#### Configuring External Store

Mantle facilitates sending large payloads with limited impact on your message bus memory usage by allowing you to
configure an external store by adding the following in the initializer.

``` Ruby
  config.external_store = { redis: Redis.new(host: 'localhost') } # default: no external store
```

#### Publishing with External Payloads

Consumers expecting external payloads will receive a third argument on the `receive` method:

```Ruby
Mantle::Message.new("person:create").publish({ id: message['id'], data: message['data'] }, { body: 'large_external_payload' } )
```

#### Retrieving External Payloads

The consumers will then receive an additional to retrieve that `external_payload` (using the same `external_store` config), by calling:

```Ruby
class MyMessageHandler
  def self.receive(channel, message, uuid)
    puts channel # => 'order'
    puts message # => { 'id' => 5, 'name' => 'Brandon' }
    puts external_store_uuid # => ''
    puts Mantle.retrieve_external_payload(uuid) # => { 'body' => 'large_external_payload' }
  end
end
```

If a consumer is only expecting to receive 2 arguments, then Mantle will detect this (using Ruby reflection), and it
will retrieve the payload and merge it into the `message`, passing this on to the `receive` method as part of `message`.

```Ruby
class MyMessageHandler
  def self.receive(channel, message)
    puts channel # => 'order'
    puts message # => { 'id' => 5, 'name' => 'Brandon', 'body' => 'large_external_payload' }
  end
end
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

