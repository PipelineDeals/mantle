require 'mantle'

module Mantle
  class << self
    def messages
      @messages ||= []
    end

    def clear_all
      @messages = []
    end
  end

  TestMessage = Struct.new(:channel, :message)

  class Message
    def initialize(channel)
      @channel = channel
    end

    def publish(message)
      Mantle.messages << TestMessage.new(channel, message)
    end
  end
end
