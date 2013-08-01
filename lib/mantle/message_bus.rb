module Mantle
  class MessageBus
    attr_reader :redis, :channels

    def initialize(channels, redis)
      @channels = channels
      @redis = redis
    end

    def run!
      catch_up
      subscribe_to_channels
    end

    def catch_up
      CatchUpHandler.new(self).catch_up!
    end

    def subscribe_to_channels
      redis.subscribe channels do |on|
        on.message do |channel, message|
          $stdout << "Message! #{channel} #{message.inspect}\n"
          MessageRouter.new(channel, message).route!
        end
      end
    end
  end
end
