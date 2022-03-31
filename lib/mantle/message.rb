module Mantle
  class Message
    attr_reader :channel
    attr_writer :message_bus, :catch_up

    def initialize(channel)
      @channel = channel
      @message_bus = Mantle::MessageBus.new
      @catch_up = Mantle::CatchUp.new
    end

    def publish(message: nil, payload: nil, expires_in: nil, keep_for: nil)
      # Add __MANTLE__ meta-data...
      mantle_meta_data(sent_at: Time.now)
      mantle_meta_data(message_source: whoami) if whoami
      mantle_meta_data(uuid: store(payload: payload, expires_in: expires_in, keep_for: keep_for)) if payload
      message[:__MANTLE__] = meta_data

      message_bus.publish(channel, message)
      catch_up.add_message(channel, message)
    end

    private

    attr_reader :message_bus, :catch_up, :meta_data

    def mantle_meta_data(meta_data)
      @meta_data ||= { }
      @meta_data.merge!(meta_data)
      @meta_data
    end

    def whoami
      Mantle.configuration.whoami
    end

    def store(payload:, expires_in:, keep_for:)
      Mantle.configuration.external_store_manager.store(payload: payload, expires_in: expires_in, keep_for: keep_for)
    end
  end
end
