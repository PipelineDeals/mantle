require 'spec_helper'

describe Mantle::Workers::ProcessWorker do
  let(:message) { {'data' => {'whatever' => 1234}} }

  describe "#perform" do
    it "processes message" do
      expect(Mantle).to receive(:receive_message).with("person:update", message) { true }
      Mantle::Workers::ProcessWorker.new.perform("person:update", message)
    end

    it "sets the last processed message" do
      allow(Mantle).to receive_messages(receive_message: true)
      expect(Mantle::LocalRedis).to receive(:set_message_successfully_received){ true }
      Mantle::Workers::ProcessWorker.new.perform("person:update", message)
    end

    it "runs the expire clean on catch up" do
      allow(Mantle).to receive_messages(receive_message: true)
      expect_any_instance_of(Mantle::CatchUp).to receive(:enqueue_clear_if_ready)
      Mantle::Workers::ProcessWorker.new.perform("person:update", message)
    end
  end
end

