module Mantle
  class ExternalStoreManager
    def configure(external_store_type, options)
      store_for(external_store_type).configure(options)
    end

    def store(payload:, keep_for: nil, expires_in: nil)
      external_store.store(payload)
    end

    def retriev(uuid:)
      external_store.retrieve(uuid)
    end

    private

    attr_accessor :external_store

    def store_for(external_store_type)
      @external_store ||= (builtin_stores[external_store_type] || external_store_type).new
    end

    def builtin_stores
      @@builtin_stores ||= {
        redis: Mantle::ExternalStore::Redis,
        active_record: Mantle::ExternalStore::ActiveRecord
      }
    end
  end
end
