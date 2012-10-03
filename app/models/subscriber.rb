class Subscriber
  def initialize(namespace, channels, handler)
    @namespace = namespace
    @channels = Array(channels)
    @handler = handler
  end

  def listen
    redis.subscribe *namespaced_channels do |on|
      on.message do |channel, message|
        receive(channel, message)
      end
    end
  end

  def receive(channel, message)
    @handler.call(channel, message)
  end

  def redis
    $redis
  end

  def namespaced_channels
    @channels.map { |channel| "#{@namespace}:#{channel}" }
  end
end