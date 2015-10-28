module Mantle
  class MessageRouter
    def initialize(channel, message)
      @channel, @message = channel, message
    end

    def route
      return unless @message

      Mantle.logger.debug("Routing message for #{@channel}")
      Mantle.logger.debug("Message: #{@message}")

      begin
        Mantle::Workers::ProcessWorker.perform_async(@channel, @message)
      rescue => e
        msg = "Unable to process Mantle message\n"
        msg += "#{e.class} #{e}\n"
        msg += "#{e.backtrace.nil? ? '' : e.backtrace.join("\n")}"
        msg += "Channel: #{@channel}"
        msg += "Message: #{@message}"
        Mantle.logger.error msg
      end
    end
  end
end
