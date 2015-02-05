module Mantle
  class MessageHandler
    def self.receive(model, action, message)
      raise Mantle::Error::MissingImplementation.new("Implement self.receive(action, model, object) and assign class to the message handler")
    end
  end
end
