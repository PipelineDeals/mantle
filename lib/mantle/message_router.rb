module Mantle
  class MessageRouter
    def initialize(action, model, message)
      @action, @model, @message = action, model, message
    end

    def route
      return unless message

      parsed_json = JSON.parse(message)

      Mantle.logger.debug("Routing message ID: #{parsed_json['id']} from #{action}:#{model}")
      Mantle.logger.debug("Message: #{parsed_json}")

      Mantle::Worker.perform_async(action, model, parsed_json)
    end

    private

    attr_reader :action, :model, :message
  end
end
