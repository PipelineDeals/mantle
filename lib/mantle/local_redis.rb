module Mantle
  class LocalRedis
    def self.set_message_successfully_received(time = Time.now.utc.to_f.to_s)
      Sidekiq.redis { |conn| conn.set('last_successful_message_received', time) }
      Mantle.logger.debug("Set last successful message received time: #{time}")
      time
    end

    def self.last_message_successfully_received_at
      result = Sidekiq.redis do |conn|
        conn.get('last_successful_message_received')
      end

      if result.nil? || result == ""
        nil
      else
        result.to_f
      end
    end

    def self.get(key)
      Sidekiq.redis { |conn| conn.get(key) }
    end
  end
end
