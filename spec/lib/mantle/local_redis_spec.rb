require 'spec_helper'

describe Mantle::LocalRedis do
  describe ".set_message_successfully_received" do
    it "saves the time" do
      time = "1234"
      Mantle::LocalRedis.set_message_successfully_received(time)
      expect(Mantle::LocalRedis.last_message_successfully_received_at).to eq(time)
    end
  end

  describe ".last_message_successfully_received_at" do
    it "retrieves the last time received" do
      time = "1234"
      Mantle::LocalRedis.set_message_successfully_received(time)
      expect(Mantle::LocalRedis.last_message_successfully_received_at).to eq(time)
    end
  end
end

