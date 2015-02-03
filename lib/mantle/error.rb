module Mantle
  module Error
    MissingChannelList = Class.new(StandardError)
    MissingRedisConnection = Class.new(StandardError)
  end
end
