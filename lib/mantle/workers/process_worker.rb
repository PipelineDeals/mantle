module Mantle
  module Workers
    class ProcessWorker
      include Sidekiq::Worker

      sidekiq_options queue: :mantle

      def perform(channel, message)
        Mantle.receive_message(channel, message)
        Mantle::LocalRedis.set_message_successfully_received
        Mantle::CatchUp.new.enqueue_clear_if_ready
      end
    end
  end
end
