module Mantle
  class MessageRouter
    def initialize(channel, message)
      @channel, @message = channel, message
    end

    def route
      return unless message

      parsed_json = parse(message)

      Mantle.logger.debug("Routing message ID: #{parsed_json['id']} from #{channel}")
      Mantle.logger.debug("Message: #{parsed_json}")

      MantleWorker.perform_async(channel, parsed_json)
    end

    private

    attr_reader :channel, :message

    def parse(json)
      JSON.parse(json)
    end
  end
end
