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

    def monitor!
      catch_up
      subscribe_to_channels
    end

    def catch_up
      CatchUpHandler.new.catch_up!
    end

    def subscribe_to_channels
      @redis.subscribe(@channels) do |on|
        on.message do |channel, message|
          $stdout << "Received message on #{channel} #{message.inspect}\n"
          _, action, model = channel.split(":")
          MessageRouter.new("#{action}:#{model}", message).route!
        end
      end
    end
  end
end
