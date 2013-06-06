require 'spec_helper'
describe Mantle::MessageRouter do
  describe "routing create messages" do
    context "when the data has an import_id" do
      let(:channel) { "namespace:create:person" }
      let(:message) { {'data' => {'import_id' => 1234}} }

      it "should create a CreateImportWorker and call perform_async on it" do
        Mantle::CreateImportWorker.should_receive(:perform_async).with(channel, message)
        Mantle::MessageRouter.new(channel, message.to_json).route!
      end
    end

    context "when the data does not have an import id" do
      let(:channel) { "namespace:create:person" }
      let(:message) { {'data' => {'whatever' => 1234}} }

      it "should create a CreateNonimportWorker and call perform_async on it" do
        Mantle::CreateNonimportWorker.should_receive(:perform_async).with(channel, message)
        Mantle::MessageRouter.new(channel, message.to_json).route!
      end
    end
  end

  describe "routing update messages" do
    let(:channel) { "namespace:update:person" }
    let(:message) { {'data' => {'whatever' => 1234}} }

    it "should create a UpdateWorker and call perform_async on it" do
      Mantle::UpdateWorker.should_receive(:perform_async).with(channel, message)
      Mantle::MessageRouter.new(channel, message.to_json).route!
    end
  end

  describe "routing delete messages" do
    let(:channel) { "namespace:destroy:person" }
    let(:message) { {'data' => {'whatever' => 1234}} }

    it "should create a UpdateWorker and call perform_async on it" do
      Mantle::DeleteWorker.should_receive(:perform_async).with(channel, message)
      Mantle::MessageRouter.new(channel, message.to_json).route!
    end
  end

  describe "raising if we do not know the action" do
    let(:channel) { "namespace:yooo:person" }
    it "should raise" do
      lambda { Mantle::MessageRouter.new(channel, nil).route! }.should raise_error(ArgumentError)
    end
  end
end
