module Mantle
  class Error < StandardError
    MissingRedisConnection = Class.new(Error)

    class MissingImplementation < Error
      def message
        "Implement self.receive(channel, object) and assign class to the message handler"
      end
    end

    class ChannelNotFound < Error
      def initialize(channel, channels)
        @channel, @channels = channel, channels
      end

      def message
        "'#{@channel}' not found. Existing channels: #{@channels.join(', ')}"
      end
    end
  end
end
