require 'spec_helper'

describe Mantle::MessageRouter do
  let(:message) { {'data' => {'whatever' => 1234}} }

  describe "#route" do
    it "doesn't enqueue a job if no message is supplied" do
        expect {
          Mantle::MessageRouter.new(channel_key("create"), nil).route
        }.to_not change{ Mantle::Worker.jobs.size }
    end

    context "routing create messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new(channel_key("create"), message.to_json).route
        }.to change(Mantle::Worker.jobs, :size).by(1)

        args = Mantle::Worker.jobs.first["args"]
        expect(args.first).to eq(channel_key("create"))
        expect(args.last).to eq(message)
      end
    end

    context "routing update messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new(channel_key("update"), message.to_json).route
        }.to change(Mantle::Worker.jobs, :size).by(1)

        args = Mantle::Worker.jobs.first["args"]
        expect(args.first).to eq(channel_key("update"))
        expect(args.last).to eq(message)
      end
    end

    context "routing delete messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new(channel_key("delete"), message.to_json).route
        }.to change(Mantle::Worker.jobs, :size).by(1)

        args = Mantle::Worker.jobs.first["args"]
        expect(args.first).to eq(channel_key("delete"))
        expect(args.last).to eq(message)
      end
    end

    context "routing non-CRUD messages" do
      it "enqueues job and gets message" do
        expect {
          Mantle::MessageRouter.new("login:user", message.to_json).route
        }.to change(Mantle::Worker.jobs, :size).by(1)

        args = Mantle::Worker.jobs.first["args"]
        expect(args.first).to eq("login:user")
        expect(args.last).to eq(message)
      end
    end
  end


  def channel_key(action)
    "#{action}:person"
  end
end
