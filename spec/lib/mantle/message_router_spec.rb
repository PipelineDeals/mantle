require 'spec_helper'

describe Mantle::MessageRouter do
  let(:message) { {'data' => {'whatever' => 1234}} }

  describe "#route" do
    it "doesn't enqueue a job if no message is supplied" do
        expect {
          Mantle::MessageRouter.new("person", "create", nil).route
        }.to_not change{ Mantle::Workers::ProcessWorker.jobs.size }
    end

    context "routing create messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("person", "create", message.to_json).route
        }.to change(Mantle::Workers::ProcessWorker.jobs, :size).by(1)

        args = Mantle::Workers::ProcessWorker.jobs.first["args"]
        expect(args.first).to eq("person")
        expect(args[1]).to eq("create")
        expect(args.last).to eq(message)
      end
    end

    context "routing update messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("person", "update", message.to_json).route
        }.to change(Mantle::Workers::ProcessWorker.jobs, :size).by(1)

        args = Mantle::Workers::ProcessWorker.jobs.first["args"]
        expect(args.first).to eq("person")
        expect(args[1]).to eq("update")
        expect(args.last).to eq(message)
      end
    end

    context "routing delete messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("person", "delete", message.to_json).route
        }.to change(Mantle::Workers::ProcessWorker.jobs, :size).by(1)

        args = Mantle::Workers::ProcessWorker.jobs.first["args"]
        expect(args.first).to eq("person")
        expect(args[1]).to eq("delete")
        expect(args.last).to eq(message)
      end
    end

    context "routing non-CRUD messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("user", "login", message.to_json).route
        }.to change(Mantle::Workers::ProcessWorker.jobs, :size).by(1)

        args = Mantle::Workers::ProcessWorker.jobs.first["args"]
        expect(args.first).to eq("user")
        expect(args[1]).to eq("login")
        expect(args.last).to eq(message)
      end
    end
  end
end
