require 'redis'

class RedisRunner
  def initialize
    $redis = Redis.new#(:host => 'topic-staging.pipelinedealsco.com')
    @namespace = 'jupiter'
    @handler = ModelHandler.new
  end

  def run!
    catchup
    start_listener
  end

  private

  def catchup
    keys = $redis.keys('jupiter:action_list:*')
    keys.each do |key|
      ns, list, timestamp, model, action, id = key.split(':')
      if timestamp.to_f > 1349147313.266263 # TODO Change to dynamically saved value
        channel = "#{@namespace}:#{action}:#{model}"
        message = $redis.get key
        @handler.call(channel, message)
      end
    end
  end

  def start_listener
    models = %w{person contact lead company deal note}
    actions = %w{create update destroy}

    channels = []
    models.each do |model|
      actions.each do |action|
        channels << "#{action}:#{model}"
      end
    end

    # TODO Didn't work
    # channels = models.map { |model| actions.map { |action| "#{action}:#{model}" } }

    Subscriber.new(@namespace, channels, @handler).listen
  end
end

RedisRunner.new.run!