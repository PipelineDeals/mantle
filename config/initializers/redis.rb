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
    time = Settings.last_success
    if time
      sig_length = compare_times(Time.now.to_i.to_s, time.to_i.to_s)
      if sig_length
        prefix = time.to_i.to_s[0, sig_length]
        keys = $redis.keys("jupiter:action_list:#{prefix}*")
        keys.each do |key|
          ns, list, timestamp, model, action, id = key.split(':')
          if timestamp.to_f > time
            channel = "#{@namespace}:#{action}:#{model}"
            message = $redis.get key
            @handler.call(channel, message)
          end
        end
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

  def compare_times(t1, t2)
    for i in 0...t1.length
      if t1[i] != t2[i]
        return i
      end
    end
    false
  end
end

RedisRunner.new.run!