require 'rubygems'
require 'redis'
require 'sidekiq'
require 'json'

require_relative './mantle/local_redis'
require_relative 'mantle/message_router'
require_relative 'mantle/catch_up_handler'
require_relative 'mantle/outside_redis_listener'
require_relative 'mantle/message_handler'
require_relative 'workers/worker'

Dir[File.dirname(__FILE__) + '/workers/*.rb'].each {|file| require file }

module Mantle
  def self.run!
    setup_sidekiq
    OutsideRedisListener.new(:namespace => 'jupiter').run!
  end

  private

  def self.setup_sidekiq
    Sidekiq.configure_client do |config|
      config.redis = { :namespace => 'mantle', :size => 1}
    end
    Sidekiq.configure_server do |config|
      config.redis = { :namespace => 'mantle' }
    end
  end
end
