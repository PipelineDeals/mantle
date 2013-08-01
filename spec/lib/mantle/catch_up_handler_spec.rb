require 'spec_helper'
describe Mantle::CatchUpHandler do
  let(:handler) { Mantle::CatchUpHandler.new(double) }

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

  describe "#sort_keys" do
    let(:keys) { ["jupiter:action_list:1370533530.12034:contact:update:106", "jupiter:action_list:1370533458.10278:contact:update:107", "jupiter:action_list:1370533534.67259:contact:update:103", "jupiter:action_list:1370533526.42493:contact:update:108"] }
    let(:sorted_keys) { ["jupiter:action_list:1370533458.10278:contact:update:107", "jupiter:action_list:1370533526.42493:contact:update:108", "jupiter:action_list:1370533530.12034:contact:update:106", "jupiter:action_list:1370533534.67259:contact:update:103"] }

    it "should sort the keys" do
      handler.sort_keys(keys).should eql(sorted_keys)
    end
  end

  describe "#get_keys_to_catch_up_on" do
    let(:keys) { ["jupiter:action_list:1370533530.12034:contact:update:106", "jupiter:action_list:1370533458.10278:contact:update:107", "jupiter:action_list:1370533534.67259:contact:update:103", "jupiter:action_list:1370533526.42493:contact:update:108"] }
    let(:keys_not_seen) { ["jupiter:action_list:1370533530.12034:contact:update:106", "jupiter:action_list:1370533534.67259:contact:update:103"] }

    it "should find the right keys" do
      handler.stub(:last_success_time).and_return(Time.at(1370533_529))
      Time.stub(:now).and_return(Time.at(1370533_560))
      handler.outside_listener.stub(:keys).with("#{Mantle::CatchUpHandler::ActionListName}:13705335*").and_return(keys_not_seen)
      handler.get_keys_to_catch_up_on.should eql(keys_not_seen)
    end
  end
end

