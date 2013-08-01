module Mantle
  class LocalRedis
    def self.set_message_successfully_received
      Sidekiq.redis do |conn|
        conn.set('last_successful_message_received', Time.now.to_i)
      end
    end

    def self.last_message_successfully_received_at
      Sidekiq.redis do |conn|
        conn.get('last_successful_message_received')
      end
    end

    def self.get(key)
      Sidekiq.redis { |conn| conn.get(key) }
    end
  end
end
