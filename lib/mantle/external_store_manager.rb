module Mantle
  class ExternalStoreManager
    def self.store(external_store:, external_payload:)
      classify(external_store).new.store(external_payload)
    end

    def self.retriev(external_store:, uuid:_)
      classify(external_store).new.retrieve(uuid)
    end

    def self.classify(external_store)
      builtin_stores[external_store.to_sym] || external_store
    end

    def self.builtin_stores
      @builtin_stores ||= {
        redis: Mantle::ExternalStore::Redis,
        active_record: Mantle::ExternalStore::ActiveRecord
      }
    end
  end
end
