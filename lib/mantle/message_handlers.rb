module Mantle
  class MessageHandlers < SimpleDelegator
    def initialize(hash_instance = {})
      super hash_instance
    end

    def receive_message(channel, message)
      each_handler channel do |handler|
        handler.receive channel, message
      end
    end

    def channels
      keys
    end

    private

    def each_handler(channel)
      Array(fetch(channel)).each do |handler|
        yield Object.const_get(handler)
      end
    rescue KeyError
      raise Mantle::Error::ChannelNotFound.new(channel, channels)
    end
  end
end
