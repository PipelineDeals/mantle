require 'mantle'
require 'pry'
require 'sidekiq/testing'


RSpec.configure do |config|
  config.before(:each) do
    Mantle.configure do |config|
      config.message_bus_redis = Redis.new(host: "localhost", db: 9)
    end

    Sidekiq::Worker.clear_all
  end
end
