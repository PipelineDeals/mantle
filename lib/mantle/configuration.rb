module Mantle
  class Configuration
    attr_accessor :message_bus_redis,
                  :logger,
                  :redis_namespace,
                  :whoami

    attr_reader   :message_handlers,
                  :external_store_manager

    def initialize
      @message_handlers = Mantle::MessageHandlers.new
      @logger = Logger.new
      @redis_namespace = nil
    end

    def message_handlers=(hash_instance)
      @message_handlers = Mantle::MessageHandlers.new(hash_instance)
    end

    def external_store=(args)
      external_store, options = args
      @external_store_manager ||= Mantle::ExternalStoreManager.new
      @external_store_manager.configure(external_store, options || {})
    end
  end
end
