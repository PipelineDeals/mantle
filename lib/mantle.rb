require 'rubygems'
require 'redis'
require 'sidekiq'
require 'json'

begin
  require 'pry'
rescue LoadError
end

require_relative 'mantle/catch_up'
require_relative 'mantle/configuration'
require_relative 'mantle/error'
require_relative 'mantle/local_redis'
require_relative 'mantle/message'
require_relative 'mantle/message_bus'
require_relative 'mantle/message_handler'
require_relative 'mantle/message_router'
require_relative 'mantle/workers/catch_up_cleanup_worker'
require_relative 'mantle/workers/process_worker'
require_relative 'mantle/version'

module Mantle
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  def self.receive_message(channel, message)
    Mantle.logger.debug("Message received on channel: #{channel}")
    Mantle.logger.debug("Mantle message: #{message}")

    self.configuration.message_handler.receive(channel, message)
  end

  def self.logger
    configuration.logger
  end
end
