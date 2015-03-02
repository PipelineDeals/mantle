require 'optparse'
require 'fileutils'

require 'mantle'

module Mantle
  class CLI

    def initialize
      @options = {}
    end

    def setup(args = ARGV)
      parse_options(args)
      load_config
      configure_sidekiq
    end

    def parse_options(args)
      optparser = OptionParser.new do |opts|
        opts.banner = "Usage: mantle <command> [options]"

        opts.on("-c", "--config CONFIG_FILE",
                "Path to configuration file (initializer)") do |arg|
          options[:config] = arg
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("--version", "Show version") do
          puts ::Mantle::VERSION
          exit
        end
      end

      optparser.parse!(args)
    end

    def load_config
      if options[:config]
        require File.expand_path(options[:config])
      else
        require File.expand_path("./config/initializers/mantle")
      end
    end

    def configure_sidekiq
      if namespace = Mantle.configuration.redis_namespace
        Sidekiq.configure_client do |config|
          config.redis = { url: ENV["REDIS_URL"], namespace: namespace }
        end
      end
    end

    def listen
      Mantle::MessageBus.new.listen
    end

    private

    attr_reader :options
  end
end

