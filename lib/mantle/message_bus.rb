module Mantle
  class MessageBus
    MissingChannelList = Class.new(StandardError)
    MissingRedisConnection = Class.new(StandardError)

    def initialize
      @redis = Mantle.message_bus_redis
      raise MissingRedisConnection unless @redis

      @channels = Mantle.message_bus_channels
      raise MissingChannelList unless @channels
    end

    def listen!
      Mantle.logger.info("Connecting to message bus redis: #{@redis.inspect} ")
      catch_up
      subscribe_to_channels
    end

    def catch_up
      CatchUpHandler.new.catch_up!
    end

    def subscribe_to_channels
      Mantle.logger.info("Initializing message bus monitoring for #{@channels} ")

      @redis.subscribe(@channels) do |on|
        on.message do |channel, message|
          action, model = channel.split(":")
          MessageRouter.new("#{action}:#{model}", message).route!
        end
      end
    end
  end
end
