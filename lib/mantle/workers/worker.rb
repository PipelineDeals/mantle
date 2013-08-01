module Mantle
  class Worker
    include Sidekiq::Worker

    def perform(channel, message)
      action = channel.split(':')[0]
      model = channel.split(':')[1]
      Mantle.receive_message(action, model, message)
      LocalRedis.set_message_successfully_received
    end
  end
end
