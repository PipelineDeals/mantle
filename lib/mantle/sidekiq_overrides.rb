require 'sidekiq'
require 'sidekiq/cli'
module Sidekiq
  class CLI
    private

    def validate!
      options[:queues] << 'default' if options[:queues].empty?
      # if !File.exist?(options[:require]) ||
      #    (File.directory?(options[:require]) && !File.exist?("#{options[:require]}/config/application.rb"))
      #   logger.info "=================================================================="
      #   logger.info "  Please point sidekiq to a Rails 3 application or a Ruby file    "
      #   logger.info "  to load your worker classes with -r [DIR|FILE]."
      #   logger.info "=================================================================="
      #   logger.info @parser
      #   die(1)
      # end
    end

    def boot_system
      ENV['RACK_ENV'] = ENV['RAILS_ENV'] = environment

      if File.directory?(options[:require])
        require 'rails'
        require 'sidekiq/rails'
        require File.expand_path("#{options[:require]}/config/environment.rb")
        ::Rails.application.eager_load!
        options[:tag] ||= default_tag
      else
        require options[:require]
      end
    end
  end
end
