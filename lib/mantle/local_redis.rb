module Mantle
  class LocalRedis
    class << self
      def set_message_successfully_received
        Sidekiq.redis do |conn|
          conn.set('last_successful_message_received', Time.now.to_i)
        end
      end

      def last_message_successfully_received_at
        Sidekiq.redis do |conn|
          conn.get('last_successful_message_received')
        end
      end

      def get(key)
        Sidekiq.redis do |conn|
          conn.get key
        end
      end
    end
  end
end
