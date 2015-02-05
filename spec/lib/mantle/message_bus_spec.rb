require 'spec_helper'

describe Mantle::MessageBus do
  describe "#publish" do
    it "sends the message to the message on the right channel" do
      redis = double("redis")
      channel = "create:deal"
      message = { id: 1 }

      mb = Mantle::MessageBus.new
      mb.redis = redis

      expect(redis).to receive(:publish).with(channel, message)

      mb.publish(channel, message)
    end
  end

  describe "#listen" do
    it "delegates to catch up" do
      # Don't want to see the output of the log
      Mantle.logger.level = Logger::WARN

      mb = Mantle::MessageBus.new
      expect(mb).to receive(:catch_up) { true }
      expect(mb).to receive(:subscribe_to_channels) { true }

      mb.listen
    end
  end

  describe "#catchup" do
    it "delegates to the catch up handler" do
      expect_any_instance_of(Mantle::CatchUp).to receive(:catch_up)
      Mantle::MessageBus.new.catch_up
    end
  end

  describe "#subscribe_to_channels" do
    it "raises without redis connection" do
      mb = Mantle::MessageBus.new
      expect {
        mb.subscribe_to_channels
      }.to raise_error(Mantle::Error::MissingRedisConnection)
    end
  end
end
