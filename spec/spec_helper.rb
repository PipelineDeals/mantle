require 'mantle'
require 'pry'
require 'sidekiq/testing'


RSpec.configure do |config|
  config.before(:each) do

    Mantle.configure do |config|
      config.message_bus_redis = Redis.new(host: "localhost", db: 9)
    end

    Mantle::LocalRedis.set_message_successfully_received(nil)
    Mantle::LocalRedis.set_catch_up_cleanup(nil)

    Sidekiq::Worker.clear_all
  end
end
