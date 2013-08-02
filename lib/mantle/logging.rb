require 'logger'

module Mantle
  module Logging
    def self.logger
      @logger || default_logger
    end

    def self.logger=(log)
      @logger = log
    end

    private

    def self.default_logger
      @logger = Logger.new(STDOUT)
      @logger
    end
  end
end
