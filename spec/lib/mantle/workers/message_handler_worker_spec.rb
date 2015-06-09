require 'spec_helper'

describe Mantle::Workers::MessageHandlerWorker do
  let(:channel) { "person:create" }
  let(:message) { {'data' => {'whatever' => 1234}} }

  describe "#perform" do
    it "delegates to handler with channel/message" do
      expect(FakeHandler).to receive(:receive).with(channel, message)
      Mantle::Workers::MessageHandlerWorker.new.perform("FakeHandler", channel, message)
    end
  end
end

class FakeHandler
  def self.receive(channel, message)
  end
end


