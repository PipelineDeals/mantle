module Mantle
  class Worker
    include Sidekiq::Worker

    def perform(channel, message)
      object = JSON.parse(message)['data']
      action = channel.split(':')[1]
      MessageHandler.receive(action, name, object)
      LocalRedis.set_message_successfully_received
    end
  end
end
