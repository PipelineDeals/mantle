module Mantle
  class LocalRedis
    SUCCESSFUL_MESSAGE_KEY = "last_successful_message_received"
    CATCH_UP_CLEANUP_KEY = "mantle:catch_up:cleanup"

    def self.set_message_successfully_received(time = Time.now.utc.to_f.to_s)
      Sidekiq.redis { |conn| conn.set(SUCCESSFUL_MESSAGE_KEY, time) }
      Mantle.logger.debug("Set last successful message received time: #{time}")
      process_redis_response(time)
    end

    def self.last_message_successfully_received_at
      result = Sidekiq.redis { |conn| conn.get(SUCCESSFUL_MESSAGE_KEY) }
      process_redis_response(result)
    end

    def self.set_catch_up_cleanup(time = Time.now.utf.to_f.to_s)
      Sidekiq.redis { |conn| conn.set(CATCH_UP_CLEANUP_KEY, time) }
      Mantle.logger.debug("Set last catch up cleanup time: #{time}")
      process_redis_response(time)
    end

    def self.last_catch_up_cleanup_at
      result = Sidekiq.redis { |conn| conn.get(CATCH_UP_CLEANUP_KEY) }
      process_redis_response(result)
    end

    private

    def self.process_redis_response(result)
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
