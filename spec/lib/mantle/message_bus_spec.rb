require 'spec_helper'

describe Mantle::MessageBus do
  describe "#publish" do
    it "sends the message to the message on the right channel" do
      redis = double("redis")
      channel = "create:deal"
      message = { id: 1 }
      json_message = JSON.generate(message)

      mb = Mantle::MessageBus.new
      mb.redis = redis

      expect(redis).to receive(:publish).with(channel, json_message)

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
    context 'properly setup message handlers' do
      before :each do
        Mantle.configure do |c|
          c.message_handlers = {
          "order" => "OrderHandler",
          "call" => "CallHandler"
          }
        end
      end

      it "subscribes to channels configured" do
        redis = double("redis")
        mb = Mantle::MessageBus.new
        mb.redis = redis

        expect(redis).to receive(:subscribe).with(["order", "call"]) { true }
        mb.subscribe_to_channels
      end
    end

    it "skips subscription if no channels" do
      redis = double("redis")
      mb = Mantle::MessageBus.new
      mb.redis = redis

      expect(redis).to_not receive(:subscribe) { true }
      mb.subscribe_to_channels
    end

    it "raises without redis connection" do
      mb = Mantle::MessageBus.new
      mb.redis = nil

      expect {
        mb.subscribe_to_channels
      }.to raise_error(Mantle::Error::MissingRedisConnection)
    end
  end
end
