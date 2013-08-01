require 'spec_helper'
describe Mantle::MessageRouter do
  let(:message) { {'data' => {'whatever' => 1234}} }

  describe "routing create messages" do
    context "when the data has an import_id" do
      let(:message) { {'data' => {'import_id' => 1234}} }

      it "creates a CreateImportWorker and call perform_async on it" do
        Mantle::CreateImportWorker.should_receive(:perform_async).with(channel_key("create"), message)
        Mantle::MessageRouter.new(channel_key("create"), message.to_json).route!
      end
    end

    context "when the data does not have an import id" do
      it "creates a CreateNonimportWorker and call perform_async on it" do
        Mantle::CreateNonimportWorker.should_receive(:perform_async).with(channel_key("create"), message)
        Mantle::MessageRouter.new(channel_key("create"), message.to_json).route!
      end
    end
  end

  describe "routing update messages" do
    it "creates a UpdateWorker and call perform_async on it" do
      Mantle::UpdateWorker.should_receive(:perform_async).with(channel_key("update"), message)
      Mantle::MessageRouter.new(channel_key("update"), message.to_json).route!
    end
  end

  describe "routing delete messages" do
    it "creates a UpdateWorker and call perform_async on it" do
      Mantle::DeleteWorker.should_receive(:perform_async).with(channel_key("destroy"), message)
      Mantle::MessageRouter.new(channel_key("destroy"), message.to_json).route!
    end
  end

  describe "raising if we do not know the action" do
    it "raises UnknownAction" do
      expect { Mantle::MessageRouter.new(channel_key("yooo"), message).route! }.to raise_error(Mantle::MessageRouter::UnknownAction)
    end
  end

  def channel_key(action)
    "#{action}:person"
  end
end
