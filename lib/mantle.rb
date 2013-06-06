require 'rubygems'
require 'redis'
require 'sidekiq'
require 'json'

require 'local_redis'
require 'catch_up_handler'
require 'outside_redis_listener'
require_relative 'workers/worker'

Dir[File.dirname(__FILE__) + '/workers/*.rb'].each {|file| require file }
