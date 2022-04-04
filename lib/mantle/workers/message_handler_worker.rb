module Mantle
  module Workers
    class MessageHandlerWorker
      include Sidekiq::Worker

      sidekiq_options queue: :mantle

      attr_reader :handler, :channel, :message, :uuid

      def perform(string_handler, channel, message)
        @handler = Object.const_get(string_handler)
        @channel = channel
        @message = message

        # Use reflection to decide what to do here...
        notify_handler
      end

      def notify_handler
        merge_payload_if_needed

        case
          when uses_named_arguments? && expects_uuid?
            handler.receive(channel: channel, message: message, uuid: uuid)
          when uses_named_arguments? && !expects_uuid?
            handler.receive(channel: channel, message: message)
          when !uses_named_arguments? && expects_uuid?
            handler.receive(channel, message, uuid: uuid)
          when !uses_named_arguments? && !expects_uuid?
            handler.receive(channel, message)
          end
      end

      def merge_payload_if_needed
        if uuid && !expects_uuid?
          payload = Mantle.external_store_manager.retrieve(uuid)
          # This will work if both are hashes...
          message.merge!(payload)
        end
      end

      def expects_uuid?
        handler_method.parameters.include?([:key,:uuid]) || handler_method.parameters.include?([:keyreq,:uuid])
      end

      def uses_named_arguments?
        handler_method.parameters.include?([:req,:channel]) && handler_method.parameters.include?([:req,:message]) 
      end

      def handler_method
        @handler_method ||= handler.method(:receive)
      end
    end
  end
end
