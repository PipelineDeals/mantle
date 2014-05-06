# Mantle

## Installation

Add this line to your application's Gemfile:

    gem 'mantle'

or install manually by:

    $ gem install mantle


## Usage

Create a file named `initializer.rb` in the root of the application specify setup:

```Ruby
require_relative 'lib/my_awesome_app'

Mantle.configure do |config|
  config.message_bus_channels = ['update:deal', 'create:deal']
  config.message_bus_redis = Redis::Namespace.new(:jupiter, :redis => Redis.new)
  config.message_bus_catch_up_key_name = "action_list"
  config.message_handler = MyAwesomeApp::MessageHandler
end
```

The `message_handler` class must implement a class method `receive` that looks like this:

```Ruby
module GlobalSearch
  class MessageHandler
    def self.receive(action, model, message)
      puts action # => 'update'
      puts model # => 'deal'
      puts message # => { 'id' => 5, 'name' => 'Brandon' }
    end
  end
end
```

## Monitor

Mount in a rack app:

```ruby
# config.ru

require './lib/pipeline_dogfood'
require 'mantle/monitor'

run Rack::URLMap.new('/' => PipelineDogfood::App, '/sidekiq' =>
Mantle::Monitor)
```
