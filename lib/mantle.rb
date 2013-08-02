require 'rubygems'
require 'redis'
require 'sidekiq'
require 'json'

begin
  require 'pry'
rescue LoadError
end

require_relative 'mantle/catch_up_handler'
require_relative 'mantle/load_workers'
require_relative 'mantle/local_redis'
require_relative 'mantle/logging'
require_relative 'mantle/message_bus'
require_relative 'mantle/message_router'

module Mantle
  MissingMessageHandler = Class.new(StandardError)

  class << self
    attr_accessor :message_bus_channels, :message_bus_redis, :message_bus_catch_up_key_name, :message_handler

    # SubscribedModels = %w{person contact lead company deal note comment}
    # SubscribedActions = %w{create update delete}
    # Mantle.configure do |config|
    #   config.message_bus_channels = ['update:deal', 'create:person']
    #   config.message_bus_redis = Redis::Namespace.new(:jupiter, :redis => Redis.new)
    #   config.message_bus_catch_up_key_name = "action_list"
    #   config.message_handler = MyAwesomeApp::MessageHandler
    # end
    #
    def configure
      yield self
      true
    end

    def run!
      MessageBus.new.listen!
    end

    def receive_message(action, model, message)
      raise MissingMessageHandler, "Implement self.receive(action, model, object) and assign class to Mantle.message_handler" unless message_handler
      Mantle.logger.info("Handler received #{action} for #{model} ID: #{message['id']}")
      Mantle.logger.debug(message)
      message_handler.receive(action, model, message)
    end

    def logger
      Mantle::Logging.logger
    end

    def logger=(log)
      Mantle::Logging.logger = log
    end

    def boot_system
      configure_sidekiq
    end

    private

    def configure_sidekiq
      Sidekiq.configure_client do |config|
        config.redis = { :namespace => :mantle, :size => 1 }
      end

      Sidekiq.configure_server do |config|
        config.redis = { :namespace => :mantle }
      end

      Sidekiq.logger = Mantle.logger
    end
  end
end

