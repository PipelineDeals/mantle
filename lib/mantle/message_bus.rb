module Mantle
  class MessageBus

    attr_writer :redis

    def initialize
      @redis = Mantle.message_bus_redis
      @channels = Mantle.message_bus_channels
    end

    def listen
      Mantle.logger.info("Connecting to message bus redis: #{redis.inspect} ")

      catch_up
      subscribe_to_channels
    end

    def catch_up
      CatchUpHandler.new.catch_up!
    end

    def subscribe_to_channels
      raise Mantle::Error::MissingRedisConnection unless redis
      raise Mantle::Error::MissingChannelList unless channels

      Mantle.logger.info("Subscribing to message bus for #{channels} ")

      redis.subscribe(channels) do |on|
        on.message do |channel, message|
          action, model = channel.split(":")
          MessageRouter.new("#{action}:#{model}", message).route!
        end
      end
    end

    private

    attr_reader :redis, :channels
  end
end
