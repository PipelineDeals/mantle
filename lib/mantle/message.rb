module Mantle
  class Message
    attr_reader :channel
    attr_writer :message_bus, :catch_up

    def initialize(channel)
      @channel = channel
      @message_bus = Mantle::MessageBus.new
      @catch_up = Mantle::CatchUp.new
    end

    def publish(message, external_payload = nil)
      message = message.merge(__MANTLE__: { message_source: whoami }) if whoami
      message = message.merge(external_payload: store(external_payload)) if external_payload
      message_bus.publish(channel, message)
      catch_up.add_message(channel, message)
    end

    private

    attr_reader :message_bus, :catch_up

    def whoami
      Mantle.configuration.whoami
    end

    def store(external_store: external_store, external_payload: external_payload)
      Mantle.configuration.external_store_manager.store(external_store: external_store, external_payload: external_payload)
    end
  end
end
