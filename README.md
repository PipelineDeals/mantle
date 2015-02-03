# Mantle

## Installation

Add this line to your application's Gemfile:

    gem 'mantle'

or install manually by:

    $ gem install mantle


## Usage (in Rails App)


Define message handler class with `.receive` method. For example `app/models/my_message_handler.rb`

```Ruby
class MyMessageHandler
  def self.receive(action, model, message)
    puts action # => 'update'
    puts model # => 'deal'
    puts message # => { 'id' => 5, 'name' => 'Brandon' }
  end
end
```

Setup a Rails initializer(`config/initializers/mantle.rb`):


```Ruby
require_relative '../../app/models/mantle_message_handler'

Mantle.configure do |config|
  config.message_bus_channels = %w[update:account]
  config.message_bus_redis = Redis.new(host: ENV["MESSAGE_BUS_REDIS_URL"] || 'localhost')
  config.message_handler = MantleMessageHandler
end
```

The config takes a number of options, many of which have defaults:

```
Mantle.configure do |config|
  config.message_bus_channels = ['update:deal', 'create:person'] (default: [])
  config.message_bus_redis = Redis.new(host: 'localhost') (default: localhost)
  config.message_bus_catch_up_key_name = "list" (default: "action_list")
  config.message_handler = MyMessageHandler (needs config)
  config.logger = Rails.logger (default: Logger.new(STDOUT))
end
```

To run the listener:

```Ruby
bin/mantle
```

or with configuration:

```Ruby
bin/mantle -c ./config/initializers/other_file.rb
```

To run the processor:

```ruby
bin/sidekiq -q mantle
```

If the Sidekiq worker should also listen on another queue, add that to the
command with:


```Ruby
bin/mantle listen
bin/sidekiq -q mantle -q default
```

It will NOT add the `default` queue to processing if there are other queues
enumerated using the `-q` option.
