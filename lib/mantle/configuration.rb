module Mantle
  class Configuration

    attr_accessor :message_bus_channels,
      :message_bus_redis,
      :message_handler,
      :logger,
      :redis_namespace

    def initialize
      @message_bus_channels = []
      @message_handler = Mantle::MessageHandler
      @logger = Logger.new
      @redis_namespace = nil
    end

    end
  end
end
