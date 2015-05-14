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
  end
end
