module Mantle
  class MessageBus
    MissingChannelList = Class.new
    MissingRedisConnection = Class.new

    def initialize(redis = Mantle.message_bus_redis, channels = Mantle.message_bus_channels)
      @redis = redis || MissingRedisConnection
      @channels = channels || MissingChannelList
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
          $stdout << "Message! #{channel} #{message.inspect}\n"
          MessageRouter.new(channel, message).route!
        end
      end
    end
  end
end
