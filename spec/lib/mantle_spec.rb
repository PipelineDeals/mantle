require 'spec_helper'

describe Mantle do
  describe ".configure" do
    it 'allows multiple configuration' do
      Mantle.configure { |c| }
      Mantle.configuration.message_bus_redis = "redis"
      expect(Mantle.configuration.message_bus_redis).to eq("redis")
    end
  end

  describe ".receive_message" do
    it "delegates to the given channel's message handlers" do
      class_double('MessageHandler').as_stubbed_const
      class_double('MessageHandler2').as_stubbed_const
      message = double('message')

      Mantle.configuration.message_handlers = {
        'deal:update' => ['MessageHandler', 'MessageHandler2']
      }

      expect(MessageHandler).to receive(:receive).with 'deal:update', message
      expect(MessageHandler2).to receive(:receive).with 'deal:update', message
      Mantle.receive_message 'deal:update', message
    end
  end

  describe ".logger" do
    it 'delegates to logger on configuration' do
      expect(Mantle.logger).to eq(Mantle.configuration.logger)
    end
  end
end


