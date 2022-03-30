module Mantle
  module ExternalStore
    class ActiveRecord
      def configure(options)
        @table = options[:table]
      end

      def store(external_payload)
        # TODO: implement actual store for active_record
        { external_store: :active_record,
          uuid: 'uuid' }
      end

      def retriev(uuid)
        # TODO: implement actual retrieve for active_record
      end
    end
  end
end
