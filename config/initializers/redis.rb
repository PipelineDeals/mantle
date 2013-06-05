require 'outside_redis_listener'
OutsideRedisListener.new.run! unless Rails.env.test?
