module Mantle
  class CatchUp
    attr_accessor :message_bus_redis
    attr_reader :message_bus_catch_up_key_name

    def initialize
      @message_bus_redis = Mantle.configuration.message_bus_redis
      @message_bus_catch_up_key_name = Mantle.configuration.message_bus_catch_up_key_name
    end

    def add_message(channel, message)
      json = JSON.generate(message)
      key = Mantle::CatchUp::MessageKey.new(channel)

      expiration_in_seconds = 6 * 60 # 6 hours

      message_bus_redis.setex(
        "#{message_bus_catch_up_key_name}:#{key}",
        expiration_in_seconds,
        json
      )

      Mantle.logger.debug("Added message to catch up list ('#{message_bus_catch_up_key_name}') with key: #{key}")
    end

    def catch_up
      raise Mantle::Error::MissingRedisConnection unless message_bus_redis

      Mantle.logger.info("Initialized catch up on list key: #{message_bus_catch_up_key_name}")

      return if last_success_time.nil?

      Mantle.logger.info("Catching up from time: #{last_success_time}")
      keys = get_keys_to_catch_up_on
      handle_messages_since_last_success(sort_keys(keys))
    end

    def sort_keys(keys)
      keys.sort { |k1, k2| k1.split(":")[1].to_f <=> k2.split(":")[1].to_f }
    end

    def get_keys_to_catch_up_on
      sig_length = compare_times(Time.now.to_i.to_s, last_success_time.to_i.to_s)
      return unless sig_length
      prefix = last_success_time.to_i.to_s[0, sig_length]
      message_bus_redis.keys(catch_up_key_names(prefix))
    end

    def compare_times(t1, t2)
      t1 = t1.to_s
      t2 = t2.to_s
      for i in 0...t1.length do return i if t1[i] != t2[i] end
      false
    end

    def catch_up_key_names(prefix)
      "#{message_bus_catch_up_key_name}:#{prefix}*"
    end

    def last_success_time
      LocalRedis.last_message_successfully_received_at
    end

    def handle_messages_since_last_success(keys)
      keys.each do |key|
        _, timestamp, model, action, id = key.split(':')
        if timestamp.to_f > last_success_time.to_f
          message = message_bus_redis.get(key)
          Mantle::MessageRouter.new(action, model, message).route
        end
      end
    end
  end
end
