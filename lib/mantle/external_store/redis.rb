module Mantle
  module ExternalStore
    class Redis
      def store(external_payload)
        # TODO: implement actual store for redis
        { external_store: :redis,
          uuid: 'uuid' }
      end

      def retriev(uuid)
        # TODO: implement actual retrieve for redis
      end
    end
  end
end
