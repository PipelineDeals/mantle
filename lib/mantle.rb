require 'rubygems'
require 'redis'
require 'sidekiq'
require 'json'
require 'uuidtools'

begin
  require 'pry'
rescue LoadError
end

require_relative 'mantle/catch_up'
require_relative 'mantle/configuration'
require_relative 'mantle/error'
require_relative 'mantle/external_store_manager'
require_relative 'mantle/external_store/redis'
require_relative 'mantle/external_store/active_record'
require_relative 'mantle/local_redis'
require_relative 'mantle/logger'
require_relative 'mantle/message'
require_relative 'mantle/message_bus'
require_relative 'mantle/message_handler'
require_relative 'mantle/message_handlers'
require_relative 'mantle/message_router'
require_relative 'mantle/workers/catch_up_cleanup_worker'
require_relative 'mantle/workers/message_handler_worker'
require_relative 'mantle/workers/process_worker'
require_relative 'mantle/version'

require_relative 'mantle/railtie' if defined?(Rails)

module Mantle
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration if block_given?
  end

  def self.receive_message(channel, message)
    Mantle.logger.debug("Message received on channel: #{channel}")
    Mantle.logger.debug("Mantle message: #{message}")

    self.configuration.message_handlers.receive_message channel, message
  end

  def self.external_store_manager
    configuration.external_store_manager
  end

  def self.channels
    configuration.message_handlers.channels
  end

  def self.logger
    configuration.logger
  end
end
