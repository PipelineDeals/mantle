require 'delegate'

module Mantle
  class MessageHandlers < ::SimpleDelegator
    def initialize(hash_instance = {})
      super hash_instance
    end

    def receive_message(channel, message)
      Array(fetch(channel)).each do |string_handler|
        Mantle::Workers::MessageHandlerWorker.perform_async(
          string_handler, channel, message
        )
      end
    end

    def channels
      keys
    end
  end
end
