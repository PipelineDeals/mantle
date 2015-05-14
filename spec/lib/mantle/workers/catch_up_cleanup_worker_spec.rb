require 'spec_helper'

describe Mantle::Workers::CatchUpCleanupWorker do
  describe "#perform" do
    it "clears expired messages from catch up set" do
      cu = double("catch_up")
      allow(Mantle::CatchUp).to receive_messages(new: cu)

      expect(cu).to receive(:clear_expired)
      Mantle::Workers::CatchUpCleanupWorker.new.perform
    end

    it "sets catch up cleanup time" do
      expect(Mantle::LocalRedis).to receive(:set_catch_up_cleanup)
      Mantle::Workers::CatchUpCleanupWorker.new.perform
    end
  end
end


