require 'redis'

class OutsideRedisListener
  SubscribedModels = %w{person contact lead company deal note comment}
  SubscribedActions = %w{create update delete}

  attr_accessor :redis, :handler

  def initialize
    config = load_config
    @redis = Redis.new(host: config[:server])
    @namespace = nil
    @namespace = config[:options]['namespace'] if config[:options]
  end

  def run!
    catchup
    start_listener
  end

  def catch_up
    CatchUpHandler.new(self).catch_up!
  end

  def setup_subscriber
    channels = []
    SubscribedModels.each { |model| SubscribedActions.each { |action| channels << with_namespace(action,model) } }
    @outside_redis.subscribe *channels do |on|
      on.message do |channel, message|
        receive(channel, message)
      end
    end
  end

  private

  def with_namespace(action, model)
    @namespace.present? ? "#{@namespace}:#{action}:#{model}" : "#{action}:#{model}"
  end

  def receive(channel, message)
    action = channel.split(':')[1] # TODO Repetitive?

    case action
    when 'create'
      object = JSON.parse(message)['data']
      if object['import_id']
        CreateImportWorker.perform_async(channel, message)
      else
        CreateNonimportWorker.perform_async(channel, message)
      end
    when 'update'
      UpdateWorker.perform_async(channel, message)
    when 'destroy'
      DeleteWorker.perform_async(channel, message)
    end
  end

  def start_listener
    Thread.new { setup_subscriber }
  end

  def load_config
    redis_config_path = Rails.root.to_s + '/config/redis.yml'
    config = YAML.load_file(redis_config_path.to_s)
    config[Rails.env]
  end
end

