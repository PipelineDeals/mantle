module Mantle
  module Error
    MissingRedisConnection = Class.new(StandardError)
    MissingImplementation = Class.new(StandardError)
  end
end
