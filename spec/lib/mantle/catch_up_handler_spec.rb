require 'spec_helper'

describe Mantle::CatchUpHandler do
  let(:handler) { Mantle::CatchUpHandler.new }

  before :each do
    allow(Mantle).to receive(:message_bus_catch_up_key_name) { "action_list" }
  end

  describe "catch_up!" do
    it "raises when redis connection is missing" do
      cu = Mantle::CatchUpHandler.new

      expect {
        cu.catch_up!
      }.to raise_error(Mantle::Error::MissingRedisConnection)
    end
  end

  describe "#compare_times" do
    context "when the times are the same" do
      let(:t1) { 10_000 }
      let(:t2) { 10_000 }
      it "is false" do
        expect(handler.compare_times(t1, t2)).to be_falsey
      end
    end

    context "when the last digit is different" do
      let(:t1) { 10_000 }
      let(:t2) { 10_005 }
      it "is four" do
        expect(handler.compare_times(t1, t2)).to eq 4
      end
    end
    context "when the fourth digit is different" do
      let(:t1) { 10_000 }
      let(:t2) { 10_050 }
      it "is three" do
        expect(handler.compare_times(t1, t2)).to eq 3
      end
    end

    context "when the first digit is different" do
      let(:t1) { 10_000 }
      let(:t2) { 20_050 }
      it "is three" do
        expect(handler.compare_times(t1, t2)).to eq 0
      end
    end
  end

  describe "#sort_keys" do
    let(:keys) { ["action_list:1370533530.12034:contact:update:106", "action_list:1370533458.10278:contact:update:107", "action_list:1370533534.67259:contact:update:103", "action_list:1370533526.42493:contact:update:108"] }
    let(:sorted_keys) { ["action_list:1370533458.10278:contact:update:107", "action_list:1370533526.42493:contact:update:108", "action_list:1370533530.12034:contact:update:106", "action_list:1370533534.67259:contact:update:103"] }

    it "sorts the keys" do
      expect(handler.sort_keys(keys)).to eq sorted_keys
    end
  end

  describe "#get_keys_to_catch_up_on" do
    let(:keys) { ["action_list:1370533530.12034:contact:update:106", "action_list:1370533458.10278:contact:update:107", "action_list:1370533534.67259:contact:update:103", "action_list:1370533526.42493:contact:update:108"] }
    let(:keys_not_seen) { ["action_list:1370533530.12034:contact:update:106", "action_list:1370533534.67259:contact:update:103"] }

    it "finds the right keys" do
      allow(handler).to receive(:last_success_time) { Time.at(1370533_529) }
      allow(Time).to receive(:now) { Time.at(1370533_560) }
      allow(handler.message_bus_redis).
          to receive(:keys).with("#{Mantle.message_bus_catch_up_key_name}:13705335*") { keys_not_seen }
      expect(handler.get_keys_to_catch_up_on).to eq keys_not_seen
    end
  end
end

