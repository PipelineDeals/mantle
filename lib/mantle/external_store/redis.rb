module Mantle
  module ExternalStore
    class Redis
      def configure(options)
        @redis = options[:redis]
      end

      def store(external_payload)
        uuid = new_uuid
        @redis.set(uuid, external_payload)
        { external_store: :redis,
          uuid: uuid }
      end

      def retriev(uuid)
        # TODO: implement actual retrieve for redis
        @redis.get(uuid)
      end

      private

      def new_uuid
        UUIDTools::UUID.timestamp_create.to_s
      end
    end
  end
end
