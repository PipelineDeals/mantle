require 'logger'

module Mantle
  class Logger < Logger
    def initialize
      super STDOUT
      self.level = Logger::INFO
      self
    end
  end
end
