require 'spec_helper'

describe Mantle::Workers::MessageHandlerWorker do
  let(:channel) { "person:create" }
  let(:message) { {'data' => {'whatever' => 1234}} }

  describe "#perform" do
    it "delegates to handler with channel/message" do
      class_double('FakeHandler').as_stubbed_const
      FakeHandler.define_singleton_method :receive do |channel, message|
      end

      expect(FakeHandler).to receive(:receive).with(channel, message)
      Mantle::Workers::MessageHandlerWorker.new.perform("FakeHandler", channel, message)
    end

    it "handles namespaced handler" do
      class_double('Namespace::FakeHandler').as_stubbed_const
      Namespace::FakeHandler.define_singleton_method :receive do |channel, message|
      end

      expect(Namespace::FakeHandler).to receive(:receive).with(channel, message)
      Mantle::Workers::MessageHandlerWorker.new.perform("Namespace::FakeHandler", channel, message)
    end
  end
end
