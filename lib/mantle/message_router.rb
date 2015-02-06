module Mantle
  class MessageRouter
    def initialize(model, action, message)
      @model, @action, @message = model, action, message
    end

    def route
      return unless message

      parsed_json = JSON.parse(message)

      Mantle.logger.debug("Routing message for #{model}:#{action}")
      Mantle.logger.debug("Message: #{parsed_json}")

      Mantle::Workers::ProcessWorker.perform_async(model, action, parsed_json)
    end

    private

    attr_reader :action, :model, :message
  end
end
