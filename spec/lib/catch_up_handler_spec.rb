require 'spec_helper'
describe Mantle::CatchUpHandler do
  let(:handler) { Mantle::CatchUpHandler.new(stub) }

  describe "#compare_times" do
    context "when the times are the same" do
      let(:t1) { 10_000 }
      let(:t2) { 10_000 }
      it "should be false" do
        handler.compare_times(t1, t2).should be_false
      end
    end

    context "when the last digit is different" do
      let(:t1) { 10_000 }
      let(:t2) { 10_005 }
      it "should be four" do
        handler.compare_times(t1, t2).should eql(4)
      end
    end
    context "when the fourth digit is different" do
      let(:t1) { 10_000 }
      let(:t2) { 10_050 }
      it "should be three" do
        handler.compare_times(t1, t2).should eql(3)
      end
    end

    context "when the first digit is different" do
      let(:t1) { 10_000 }
      let(:t2) { 20_050 }
      it "should be three" do
        handler.compare_times(t1, t2).should eql(0)
      end
    end
  end
end

