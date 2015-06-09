module Mantle
  class Configuration
    attr_accessor :message_bus_redis,
                  :logger,
                  :redis_namespace

    attr_reader :message_handlers

    def initialize
      @message_handlers = Mantle::MessageHandlers.new
      @logger = Logger.new
      @redis_namespace = nil
    end

    def message_handlers=(hash_instance)
      @message_handlers = Mantle::MessageHandlers.new(hash_instance)
    end
  end
end
