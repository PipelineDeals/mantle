module Mantle
  module Workers
    class CatchUpCleanupWorker
      include Sidekiq::Worker

      sidekiq_options queue: :mantle

      def perform
      end
    end
  end
end

