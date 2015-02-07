module Mantle
  class MessageRouter
    def initialize(channel, message)
      @channel, @message = channel, message
    end

    def route
      return unless @message

      Mantle.logger.debug("Routing message for #{@channel}")
      Mantle.logger.debug("Message: #{@message}")

      Mantle::Workers::ProcessWorker.perform_async(@channel, @message)
    end
  end
end
