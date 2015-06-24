require 'spec_helper'

describe Mantle do
  describe ".configure" do
    it 'allows multiple configuration' do
      Mantle.configure { |c| }
      Mantle.configuration.message_bus_redis = "redis"
      expect(Mantle.configuration.message_bus_redis).to eq("redis")
    end

    it 'allows message_handlers to be set' do
      handler_config = { "order" => "OrderHandler" }
      Mantle.configure { |c| c.message_handlers = handler_config }
      expect(Mantle.configuration.message_handlers).to eq(handler_config)
    end
  end

  describe ".receive_message" do
    it "delegates to the given channel's message handlers" do
      message = double('message')

      Mantle.configuration.message_handlers = {
        'deal:update' => ['MessageHandler', 'MessageHandler2']
      }

      expect(Mantle.configuration.message_handlers).to receive(:receive_message).with 'deal:update', message
      Mantle.receive_message 'deal:update', message
    end
  end

  describe ".logger" do
    it 'delegates to logger on configuration' do
      expect(Mantle.logger).to eq(Mantle.configuration.logger)
    end
  end
end


