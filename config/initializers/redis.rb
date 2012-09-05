require 'redis'

$redis = Redis.new

namespace = "jupiter"
handler = ModelHandler.new

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

Subscriber.new(namespace, channels, handler).listen