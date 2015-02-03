module Mantle
  class Worker
    include Sidekiq::Worker

    sidekiq_options queue: :mantle

    def perform(channel, message)
      action = channel.split(':')[0]
      model = channel.split(':')[1]
      Mantle.receive_message(action, model, message)
      Mantle::LocalRedis.set_message_successfully_received
    end
  end
end
