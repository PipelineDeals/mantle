module Mantle
  class MessageHandler
    def self.receive(channel, message)
      raise Mantle::Error::MissingImplementation.new("Implement self.receive(channel, object) and assign class to the message handler")
    end
  end
end
