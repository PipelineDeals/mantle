module Mantle
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc <<desc
description:
    copy mantle config to a Rails initializer and create default handler
desc

      def create_configuration
        template "mantle.rb", "config/initializers/mantle.rb"
      end

      def create_handler
        template "mantle_message_handler.rb", "app/models/mantle_message_handler.rb"
      end
    end
  end
end
