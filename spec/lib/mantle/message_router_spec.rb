require 'spec_helper'

describe Mantle::MessageRouter do
  let(:message) { {'data' => {'whatever' => 1234}} }

  describe "routing create messages" do
    it "creates a MantleWorker and call perform_async on it" do
      expect {
        Mantle::MessageRouter.new(channel_key("create"), message.to_json).route!
      }.to change(Mantle::MantleWorker.jobs, :size).by(1)

      args = Mantle::MantleWorker.jobs.first["args"]
      expect(args.first).to eq(channel_key("create"))
      expect(args.last).to eq(message)
    end
  end

  describe "routing update messages" do
    it "creates a MantleWorker and call perform_async on it" do
      expect {
        Mantle::MessageRouter.new(channel_key("update"), message.to_json).route!
      }.to change(Mantle::MantleWorker.jobs, :size).by(1)

      args = Mantle::MantleWorker.jobs.first["args"]
      expect(args.first).to eq(channel_key("update"))
      expect(args.last).to eq(message)
    end
  end

  describe "routing delete messages" do
    it "creates a MantleWorker and call perform_async on it" do
      expect {
        Mantle::MessageRouter.new(channel_key("delete"), message.to_json).route!
      }.to change(Mantle::MantleWorker.jobs, :size).by(1)

      args = Mantle::MantleWorker.jobs.first["args"]
      expect(args.first).to eq(channel_key("delete"))
      expect(args.last).to eq(message)
    end
  end

  describe "routing login messages" do
    it "creates a MantleWorker and call perform_async on it" do
      expect {
        Mantle::MessageRouter.new("login:user", message.to_json).route!
      }.to change(Mantle::MantleWorker.jobs, :size).by(1)

      args = Mantle::MantleWorker.jobs.first["args"]
      expect(args.first).to eq("login:user")
      expect(args.last).to eq(message)
    end
  end

  def channel_key(action)
    "#{action}:person"
  end
end
