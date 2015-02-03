module Mantle
  class Worker
    include Sidekiq::Worker

    sidekiq_options queue: :mantle

    def perform(action, model, message)
      Mantle.receive_message(action, model, message)
      Mantle::LocalRedis.set_message_successfully_received
    end
  end
end
