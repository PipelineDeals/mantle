require 'rubygems'
require 'redis'
require 'sidekiq'
require 'json'

begin
  require 'pry'
rescue LoadError
end

require_relative 'mantle/catch_up_handler'
require_relative 'mantle/configuration'
require_relative 'mantle/error'
require_relative 'mantle/local_redis'
require_relative 'mantle/message_bus'
require_relative 'mantle/message_handler'
require_relative 'mantle/message_router'
require_relative 'mantle/worker'

module Mantle
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.receive_message(action, model, message)
    Mantle.logger.debug("Handler received #{action} for #{model} ID: #{message['id']}")
    Mantle.logger.debug("Message: #{message}")

    self.configuration.message_handler.receive(action, model, message)
  end

  def self.logger
    configuration.logger
  end

  def self.configure_system
    configure_sidekiq
  end

  private

  def self.configure_sidekiq
    # Use when enqueueing jobs
    # Sidekiq.configure_client do |config|
    #   config.redis = { :namespace => :mantle }
    # end

    # Used when server pulls out jobs and processes
    Sidekiq.configure_server do |config|
      # config.redis = { :namespace => :mantle }

      config.server_middleware do |chain|
        chain.remove Sidekiq::Middleware::Server::Logging
      end
    end

    # Sidekiq.options = Sidekiq::DEFAULTS.merge({
    #   # concurrency: 25,
    #   # require: File.exist?('./initializer.rb') ? File.expand_path('./initializer.rb') : '.',
    #   # queues: ['mantle']
    # })

    Sidekiq.logger = Mantle.logger
  end
end
