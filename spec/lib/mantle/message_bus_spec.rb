require 'spec_helper'

describe Mantle::MessageBus do
  describe "#listen" do
    it "delegates to the catch up handler" do
      mb = Mantle::MessageBus.new
      expect(mb).to receive(:catch_up) { true }
      expect(mb).to receive(:subscribe_to_channels) { true }
      mb.listen
    end
  end

  describe "#catchup" do
    it "delegates to the catch up handler" do
      expect_any_instance_of(Mantle::CatchUpHandler).to receive(:catch_up!)
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
