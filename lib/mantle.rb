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
require_relative 'mantle/version'

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
end
