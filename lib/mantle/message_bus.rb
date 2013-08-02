module Mantle
  class MessageBus
    MissingChannelList = Class.new(StandardError)
    MissingRedisConnection = Class.new(StandardError)

    def initialize(redis = Mantle.message_bus_redis, channels = Mantle.message_bus_channels)
      @redis = redis
      raise MissingRedisConnection unless @redis

      @channels = channels
      raise MissingChannelList unless @channels
    end

    def listen!
      catch_up
      subscribe_to_channels
    end

    def catch_up
      CatchUpHandler.new.catch_up!
    end

    def subscribe_to_channels
      Mantle.logger.debug("Initializing message bus monitoring for #{@channels} ")

      @redis.subscribe(@channels) do |on|
        on.message do |channel, message|
          _, action, model = channel.split(":")
          MessageRouter.new("#{action}:#{model}", message).route!
        end
      end
    end
  end
end
