require 'spec_helper'

describe Mantle::MessageRouter do
  let(:message) { {'data' => {'whatever' => 1234}} }

  describe "#route" do
    it "doesn't enqueue a job if no message is supplied" do
        expect {
          Mantle::MessageRouter.new("person:create", nil).route
        }.to_not change{ Mantle::Workers::ProcessWorker.jobs.size }
    end

    context "routing create messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("person:create", message).route
        }.to change(Mantle::Workers::ProcessWorker.jobs, :size).by(1)

        args = Mantle::Workers::ProcessWorker.jobs.first["args"]
        expect(args.first).to eq("person:create")
        expect(args.last).to eq(message)
      end
    end

    context "routing update messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("person:update", message).route
        }.to change(Mantle::Workers::ProcessWorker.jobs, :size).by(1)

        args = Mantle::Workers::ProcessWorker.jobs.first["args"]
        expect(args.first).to eq("person:update")
        expect(args.last).to eq(message)
      end
    end

    context "routing delete messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("person:delete", message).route
        }.to change(Mantle::Workers::ProcessWorker.jobs, :size).by(1)

        args = Mantle::Workers::ProcessWorker.jobs.first["args"]
        expect(args.first).to eq("person:delete")
        expect(args.last).to eq(message)
      end
    end

    context "routing non-CRUD messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("user:login", message).route
        }.to change(Mantle::Workers::ProcessWorker.jobs, :size).by(1)

        args = Mantle::Workers::ProcessWorker.jobs.first["args"]
        expect(args.first).to eq("user:login")
        expect(args.last).to eq(message)
      end
    end

    context "processing malformed messages" do
      it "logs to error log" do
        fake_process_worker = Class.new
        stub_const("Mantle::Workers::ProcessWorker", fake_process_worker)
        allow(fake_process_worker).to receive(:perform_async) { raise JSON::GeneratorError }

        expect(Mantle.logger).to receive(:error)
        Mantle::MessageRouter.new("user:login", message).route
      end
    end
  end
end
