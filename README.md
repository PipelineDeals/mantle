# Mantle

## Installation

Add this line to your application's Gemfile:

    gem 'mantle'

or install manually by:

    $ gem install mantle


## Usage (in Rails App)

add following code to `bin/mantle` file:

```Ruby
require 'pathname'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path("../../Gemfile",
  Pathname.new(__FILE__).realpath)

require 'rubygems'
require 'bundler/setup'

load Gem.bin_path('mantle', 'mantle')
```

define class with `receive` method. For example `app/models/some_message_handler.rb`

```Ruby
class SomeMessageHandler
  def self.receive(action, model, message)
    puts action # => 'update'
    puts model # => 'deal'
    puts message # => { 'id' => 5, 'name' => 'Brandon' }
  end
end
```

then paste this code to `config/environment.rb`


```Ruby
require 'redis'
require 'redis-namespace'
require 'some_message_handler'

Mantle.configure do |config|
  config.message_bus_channels = ['update:user', 'create:user']
  config.message_bus_redis = Redis::Namespace.new(:jupiter, redis: Redis.new)
  config.message_bus_catch_up_key_name = 'action_list'
  config.message_handler = SomeMessageHandler
end
```

Note that `SomeMessageHandler` might be substituted for any class you want as long as it has `receive` method defined but you need to `require` it instead of `'some_message_handler'`

To run enter this commands:

```Ruby
bin/mantle listen
bin/mantle process
```

and remember to start application server!

## Usage (in Sinatra App)

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
