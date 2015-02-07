module Mantle
  class MessageRouter
    def initialize(model, action, message)
      @model, @action, @message = model, action, message
    end

    def route
      return unless message

      Mantle.logger.debug("Routing message for #{model}:#{action}")
      Mantle.logger.debug("Message: #{message}")

      Mantle::Workers::ProcessWorker.perform_async(model, action, message)
    end

    private

    attr_reader :action, :model, :message
  end
end
