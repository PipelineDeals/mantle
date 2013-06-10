module Mantle
  class Worker
    include Sidekiq::Worker

    def perform(channel, message)
      action = channel.split(':')[1]
      name = channel.split(':')[2]
      Mantle.receive_message(action,name,message)
      LocalRedis.set_message_successfully_received
    end
  end
end
