module Mantle
  module Workers
    class ProcessWorker
      include Sidekiq::Worker

      sidekiq_options queue: :mantle

      def perform(model, action, message)
        Mantle.receive_message(model, action, message)
        Mantle::LocalRedis.set_message_successfully_received
      end
    end
  end
end
