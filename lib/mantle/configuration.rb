require 'logger'

module Mantle
  class Configuration

    attr_accessor :message_bus_channels,
      :message_bus_redis,
      :message_handler,
      :logger

    def initialize
      @message_bus_channels = []
      @message_handler = Mantle::MessageHandler
      @logger = default_logger
    end

    private

    def default_logger
      logger = Logger.new(STDOUT)
      logger.level = Logger::INFO
      logger
    end
  end
end
