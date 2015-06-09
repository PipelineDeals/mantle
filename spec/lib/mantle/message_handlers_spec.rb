require 'spec_helper'

describe Mantle::MessageHandlers do
  describe '#receive_message' do
    it 'enqueues a job for each handler' do
      channel = "person:create"
      message = { "id" => 4 }
      message_handlers = {
        "person:create" => ['FakeHandler', 'OtherFakeHandler']
      }

      expect {
        Mantle::MessageHandlers.new(message_handlers).receive_message(channel, message)
      }.to change(Mantle::Workers::MessageHandlerWorker.jobs, :size).by(2)

      args = Mantle::Workers::MessageHandlerWorker.jobs[0]["args"]
      expect(args[0]).to eq("FakeHandler")
      expect(args[1]).to eq(channel)
      expect(args[2]).to eq(message)

      args = Mantle::Workers::MessageHandlerWorker.jobs[1]["args"]
      expect(args[0]).to eq("OtherFakeHandler")
      expect(args[1]).to eq(channel)
      expect(args[2]).to eq(message)
    end
  end
end
