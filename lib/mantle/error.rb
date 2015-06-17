module Mantle
  class Error < StandardError
    MissingRedisConnection = Class.new(Error)

    class MissingImplementation < Error
      def message
        "Implement self.receive(channel, object) and assign class to the message handler"
      end
    end
  end
end
