module Mantle
  class CatchUpHandler
    attr_reader :message_bus_redis, :message_bus_catch_up_key_name

    def initialize(message_bus_redis = Mantle.message_bus_redis, message_bus_catch_up_key_name = Mantle.message_bus_catch_up_key_name)
      @message_bus_redis = message_bus_redis
      @message_bus_catch_up_key_name = message_bus_catch_up_key_name
    end

    def catch_up!
      Mantle.logger.info("Initialized catch up on list key: #{message_bus_catch_up_key_name}")

      return if last_success_time.nil?

      Mantle.logger.info("Catching up from time: #{last_success_time}")
      keys = get_keys_to_catch_up_on
      handle_messages_since_last_success(sort_keys(keys))
    end

    def sort_keys(keys)
      keys.sort {|k1, k2| k1.split(":")[2].to_f <=> k2.split(":")[2].to_f }
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
      "#{@message_bus_catch_up_key_name}:#{prefix}*"
    end

    def last_success_time
      LocalRedis.last_message_successfully_received_at
    end

    def handle_messages_since_last_success(keys)
      keys.each do |key|
        _, timestamp, model, action, id = key.split(':')
        if timestamp.to_f > last_success_time.to_f
          channel = "#{action}:#{model}"
          message = message_bus_redis.get(key)
          MessageRouter.new(channel, message).route!
        end
      end
    end
  end
end
