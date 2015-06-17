module Mantle
  class MessageHandler
    def self.receive(channel, message)
      raise Mantle::Error::MissingImplementation
    end
  end
end
