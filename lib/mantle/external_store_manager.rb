module Mantle
  class ExternalStoreManager
    attr_accessor :external_stores

    def configure(external_store, options)
      instance(external_store).configure(options)
    end

    def store(external_store:, external_payload:)
      instance(external_store).store(external_payload)
    end

    def retriev(external_store:, uuid:_)
      instance(external_store).new.retrieve(uuid)
    end

    def instance(external_store)
      @external_stores ||= {}
      @external_stores[external_store] ||= (builtin_stores[external_store.to_sym] || external_store).new
    end

    def builtin_stores
      @@builtin_stores ||= {
        redis: Mantle::ExternalStore::Redis,
        active_record: Mantle::ExternalStore::ActiveRecord
      }
    end
  end
end
