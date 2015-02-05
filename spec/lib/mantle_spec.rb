require 'spec_helper'

describe Mantle do
  describe ".configure" do
    it 'sets up configuration' do
      Mantle.configure do |config|
        config.message_bus_catch_up_key_name = "catchup"
      end

      expect(Mantle.configuration.message_bus_catch_up_key_name).to eq("catchup")
    end

    it 'allows multiple configuration' do
      Mantle.configure do |config|
        config.message_bus_catch_up_key_name = "catchup"
      end

      Mantle.configuration.message_bus_redis = "redis"
      expect(Mantle.configuration.message_bus_redis).to eq("redis")
      expect(Mantle.configuration.message_bus_catch_up_key_name).to eq("catchup")
    end
  end

  describe ".receive_message" do
    it 'delegates to message handler' do
      expect(Mantle.configuration.message_handler).to receive(:receive).with("deal", "update", {})
      Mantle.receive_message("deal", "update", {})
    end
  end

  describe ".logger" do
    it 'delegates to logger on configuration' do
      expect(Mantle.logger).to eq(Mantle.configuration.logger)
    end
  end
end


