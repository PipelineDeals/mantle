module Mantle
  class MessageBus
    attr_writer :redis

    def initialize
      @redis = Mantle.configuration.message_bus_redis
    end

    def publish(channel, message)
      json = JSON.generate(message)
      redis.publish(channel, json)
      Mantle.logger.debug("Sent message to message bus channel: #{channel}")
    end

    def listen
      Mantle.logger.info("Connecting to message bus redis: #{redis.inspect} ")

      catch_up
      subscribe_to_channels
    end

    def catch_up
      Mantle::CatchUp.new.catch_up
    end

    def subscribe_to_channels
      raise Mantle::Error::MissingRedisConnection unless redis

      Mantle.logger.info("Subscribing to message bus for #{channels} ")

      redis.subscribe(Mantle.channels) do |on|
        on.message do |channel, json_message|
          message = JSON.parse(json_message)
          Mantle::MessageRouter.new(channel, message).route
        end
      end
    end

    private

    attr_reader :redis
  end
end
