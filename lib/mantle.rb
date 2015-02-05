require 'rubygems'
require 'redis'
require 'sidekiq'
require 'json'

begin
  require 'pry'
rescue LoadError
end

require_relative 'mantle/catch_up'
require_relative 'mantle/catch_up/message_key'
require_relative 'mantle/configuration'
require_relative 'mantle/error'
require_relative 'mantle/local_redis'
require_relative 'mantle/message'
require_relative 'mantle/message_bus'
require_relative 'mantle/message_handler'
require_relative 'mantle/message_router'
require_relative 'mantle/worker'
require_relative 'mantle/version'

module Mantle
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  def self.receive_message(action, model, message)
    Mantle.logger.debug("Handler received #{action} for #{model}")
    Mantle.logger.debug("Mantle message: #{message}")

    self.configuration.message_handler.receive(action, model, message)
  end

  def self.logger
    configuration.logger
  end
end
