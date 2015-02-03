require 'spec_helper'

describe Mantle::MessageRouter do
  let(:message) { {'data' => {'whatever' => 1234}} }

  describe "#route" do
    it "doesn't enqueue a job if no message is supplied" do
        expect {
          Mantle::MessageRouter.new("create", "person", nil).route
        }.to_not change{ Mantle::Worker.jobs.size }
    end

    context "routing create messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("create", "person", message.to_json).route
        }.to change(Mantle::Worker.jobs, :size).by(1)

        args = Mantle::Worker.jobs.first["args"]
        expect(args.first).to eq("create")
        expect(args[1]).to eq("person")
        expect(args.last).to eq(message)
      end
    end

    context "routing update messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("update", "person", message.to_json).route
        }.to change(Mantle::Worker.jobs, :size).by(1)

        args = Mantle::Worker.jobs.first["args"]
        expect(args.first).to eq("update")
        expect(args[1]).to eq("person")
        expect(args.last).to eq(message)
      end
    end

    context "routing delete messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("delete", "person", message.to_json).route
        }.to change(Mantle::Worker.jobs, :size).by(1)

        args = Mantle::Worker.jobs.first["args"]
        expect(args.first).to eq("delete")
        expect(args[1]).to eq("person")
        expect(args.last).to eq(message)
      end
    end

    context "routing non-CRUD messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("login", "user", message.to_json).route
        }.to change(Mantle::Worker.jobs, :size).by(1)

        args = Mantle::Worker.jobs.first["args"]
        expect(args.first).to eq("login")
        expect(args[1]).to eq("user")
        expect(args.last).to eq(message)
      end
    end
  end
end
