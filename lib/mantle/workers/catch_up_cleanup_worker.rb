module Mantle
  module Workers
    class CatchUpCleanupWorker
      include Sidekiq::Worker

      sidekiq_options queue: :mantle

      def perform
        Mantle::CatchUp.new.clear_expired
      end
    end
  end
end

