module Mantle
  class CatchUp
    class MessageKey
      def initialize(channel)
        @channel = channel
      end

      def key
        "#{Time.now.utc.to_f}:#{channel}"
      end

      alias_method :to_s, :key

      private

      attr_reader :channel
    end
  end
end

