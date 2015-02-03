require 'logger'

module Mantle
  class Configuration

    attr_accessor :message_bus_channels,
      :message_bus_redis,
      :message_bus_catch_up_key_name,
      :message_handler,
      :logger

    def initialize
      @message_bus_channels = []
      @message_bus_catch_up_key_name = "action_list"
      @message_handler = Mantle::MessageHandler
      @logger = Logger.new(STDOUT)
    end
  end
end