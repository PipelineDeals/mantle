module Mantle
  module Workers
    class MessageHandlerWorker
      include Sidekiq::Worker

      sidekiq_options queue: :mantle

      def perform(string_handler, channel, message)
        handler = Object.const_get(string_handler)
        handler.receive channel, message
      end
    end
  end
end

