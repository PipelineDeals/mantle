module Mantle
  class CatchUpHandler
    def initialize(outside_listener)
      @outside_listener = outside_listener
      @redis = LocalRedis.new
    end

    def catch_up!
      return if last_success_time.nil?
      keys = get_keys_to_catch_up_on
      handle_messages_since_last_success(keys)
    end

    def get_keys_to_catch_up_on
      sig_length = compare_times(Time.now.to_i.to_s, last_success_time.to_i.to_s)
      return unless sig_length.present?
      prefix = time.to_i.to_s[0, sig_length]
      @outside_listener.keys("jupiter:action_list:#{prefix}*")
    end

    def compare_times(t1, t2)
      t1 = t1.to_s
      t2 = t2.to_s
      for i in 0...t1.length do return i if t1[i] != t2[i] end
      false
    end

    def last_success_time
      @redis.last_message_successfully_received_at
    end

    def handle_messages_since_last_success(keys)
      keys.each do |key|
        ns, list, timestamp, model, action, id = key.split(':')
        if timestamp.to_f > last_success_time
          channel = "#{@namespace}:#{action}:#{model}"
          message = @redis.get key
          MessageRouter.new(channel, message).route!
        end
      end
    end
  end
end
