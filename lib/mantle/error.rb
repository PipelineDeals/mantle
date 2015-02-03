module Mantle
  module Error
    MissingChannelList = Class.new(StandardError)
    MissingRedisConnection = Class.new(StandardError)
    MissingImplementation = Class.new(StandardError)
  end
end
