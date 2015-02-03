require 'spec_helper'

describe Mantle::Worker do
  let(:message) { {'data' => {'whatever' => 1234}} }

  describe "#perform" do
    it "processes message" do
      expect(Mantle).to receive(:receive_message).with("update", "person", message) { true }
      Mantle::Worker.new.perform("update", "person", message)
    end

    it "sets the last processed message" do
      allow(Mantle).to receive_messages(receive_message: true)
      expect(Mantle::LocalRedis).to receive(:set_message_successfully_received){ true }
      Mantle::Worker.new.perform("update", "person", message)
    end
  end
end
