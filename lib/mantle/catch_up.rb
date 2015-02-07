module Mantle
  class CatchUp
    KEY = "mantle:catch_up"

    attr_accessor :redis, :message_bus_channels
    attr_reader :key

    def initialize
      @redis = Mantle.configuration.message_bus_redis
      @message_bus_channels = Mantle.configuration.message_bus_channels
      @key = KEY
    end

    def add_message(channel, message, now = Time.now.utc.to_f)
      json = serialize_payload(channel, message)
      redis.zadd(key, now, json)
      Mantle.logger.debug("Added message to catch up list for channel: #{channel}")
      now
    end

    def clear_expired(now = Time.now.utc.to_f)
      redis.zremrangebyscore(key, 0 , now)
    end

    def catch_up
      raise Mantle::Error::MissingRedisConnection unless redis

      if last_success_time.nil?
        Mantle.logger.info("Skipping catch up because of missing last processed time...")
        return
      end

      Mantle.logger.info("Catching up from time: #{last_success_time}")

      payloads_with_time = redis.zrangebyscore(key, last_success_time, 'inf', with_scores: true)
      route_messages(payloads_with_time) if payloads_with_time.any?
    end

    def last_success_time
      LocalRedis.last_message_successfully_received_at
    end

    def route_messages(payloads_with_time)
      payloads_with_time.each do |payload_with_time|
        payload, time = payload_with_time
        channel, message = deserialize_payload(payload)

        if message_bus_channels.include?(channel)
          Mantle::MessageRouter.new(channel, message).route
        end
      end
    end

    def deserialize_payload(payload)
      res = JSON.parse(payload)
      [res.fetch("channel"), res.fetch("message")]
    end

    private

    def serialize_payload(channel, message)
      payload = { channel: channel, message: message }
      JSON.generate(payload)
    end
  end
end
