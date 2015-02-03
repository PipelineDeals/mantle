module Mantle
  class MessageHandler
    def self.receive(action, model, message)
      raise Mantle::Error::MissingImplementation.new("Implement self.receive(action, model, object) and assign class to the message handler")
    end
  end
end
