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

      if Mantle.channels.any?
        Mantle.logger.info("Subscribing to message bus for #{Mantle.channels} ")
      else
        Mantle.logger.info("No channels configured for subscription. Configure 'message_handlers' if this was unintentional.") and return
      end

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
