module Mantle
  class Message
    attr_reader :channel
    attr_writer :message_bus, :catch_up

    def initialize(channel)
      @channel = channel
      @message_bus = Mantle::MessageBus.new
      @catch_up = Mantle::CatchUp.new
    end

    def method_missing(m, *args, &block)
      raise if m.to_sym != :publish

      if (args.count == 1 && (args[0].keys - [:message, :mantle, :payload, :expires_in, :keep_for]).any?)
        message = {}
        args[0].keys.reject { |k| [:message, :mantle, :payload, :expires_in, :keep_for].include?(k) }.each { |k, v| message[k] = args[0].delete(k) }
        args[0][:message] = message if message.any?
      elsif (args.count == 2)
        args[1][:message] = args.slice!(0)
      end

      self.send(:_publish, *args, &block)
    end

    private

    attr_reader :message_bus, :catch_up, :meta_data

    def _publish(message: nil, payload: nil, expires_in: nil, keep_for: nil)
      # Add __MANTLE__ meta-data...
      mantle_meta_data(sent_at: Time.now)
      mantle_meta_data(message_source: whoami) if whoami
      mantle_meta_data(uuid: store(payload: payload, expires_in: expires_in, keep_for: keep_for)) if payload
      message[:__MANTLE__] = meta_data

      message_bus.publish(channel, message)
      catch_up.add_message(channel, message)
    end

    def mantle_meta_data(meta_data)
      @meta_data ||= { }
      @meta_data.merge!(meta_data)
      @meta_data
    end

    def whoami
      Mantle.configuration.whoami
    end

    def store(payload:, expires_in:, keep_for:)
      Mantle.configuration.external_store_manager.store(payload: payload, expires_in: expires_in, keep_for: keep_for)
    end
  end
end
