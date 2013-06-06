require 'redis'

module Mantle
  class OutsideRedisListener
    SubscribedModels = %w{person contact lead company deal note comment}
    SubscribedActions = %w{create update delete}

    attr_accessor :outside_redis, :handler

    def initialize(config = {})
      @outside_redis = Redis.new(host: config[:server])
      @namespace = config[:namespace]
    end

    def run!
      catch_up
      setup_subscriber
    end

    def catch_up
      CatchUpHandler.new(self).catch_up!
    end

    def setup_subscriber
      channels = []
      SubscribedModels.each { |model| SubscribedActions.each { |action| channels << "#{@namespace}:#{action}:#{model}" } }
      @outside_redis.subscribe channels do |on|
        on.message do |channel, message|
          MessageRouter.new(channel, message).route!
        end
      end
    end
  end
end
