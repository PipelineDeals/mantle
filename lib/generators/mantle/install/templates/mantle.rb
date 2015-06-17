# require 'sidekiq-pro'

Mantle.configure do |config|
  config.message_bus_redis = Redis.new(
    host: ENV.fetch('MESSAGE_BUS_REDIS_URL', 'localhost')
  )
  config.message_handlers = {}
end

