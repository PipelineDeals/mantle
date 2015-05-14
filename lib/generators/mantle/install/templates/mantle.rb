# require 'sidekiq-pro'
require_relative '../../app/models/mantle_message_handler'

Mantle.configure do |config|
  config.message_bus_channels = %w[]
  config.message_bus_redis = Redis.new(host: ENV["MESSAGE_BUS_REDIS_URL"] || 'localhost')
  config.message_handler = MantleMessageHandler
end

