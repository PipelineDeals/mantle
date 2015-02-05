module Mantle
  class Message
    attr_reader :channel
    attr_writer :message_bus, :catch_up

    def initialize(channel)
      @channel = channel
      @message_bus = Mantle::MessageBus.new
      @catch_up = Mantle::CatchUp.new
    end

    def publish(message)
      message_bus.publish(channel, message)
      catch_up.add_message(channel, message)
    end

    private

    attr_reader :message_bus, :catch_up
  end
end
