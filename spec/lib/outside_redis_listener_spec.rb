require 'spec_helper'
describe Mantle::OutsideRedisListener do
  let(:listener) { Mantle::OutsideRedisListener.new(namespace:'dingle') }

  it "should have a redis" do
    listener.outside_redis.should be_an_instance_of Redis
  end

  describe "setup_subscriber" do
    let(:channels) {["dingle:create:person", "dingle:update:person", "dingle:delete:person", "dingle:create:contact", "dingle:update:contact", "dingle:delete:contact", "dingle:create:lead", "dingle:update:lead", "dingle:delete:lead", "dingle:create:company", "dingle:update:company", "dingle:delete:company", "dingle:create:deal", "dingle:update:deal", "dingle:delete:deal", "dingle:create:note", "dingle:update:note", "dingle:delete:note", "dingle:create:comment", "dingle:update:comment", "dingle:delete:comment"] }

    it "setup a subscriber" do
      listener.outside_redis.should_receive(:subscribe).with channels
      listener.setup_subscriber
    end
  end

  describe "catchup" do
    it "should delegate to the catch up handler" do
      Mantle::CatchUpHandler.any_instance.should_receive(:catch_up!)
      listener.catch_up
    end
  end
end
