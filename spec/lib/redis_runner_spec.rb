require 'spec_helper'

describe OutsideRedisListener do
  let(:listener) { OutsideRedisListener.new }

  it "should have a redis" do
    listener.redis.should be_an_instance_of Redis
  end

  it "should have a handler" do
    listener.handler.should be_an_instance_of ModelHandler
  end

  describe "setup_subscriber" do
    let(:channels) { ["create:person", "update:person", "delete:person", "create:contact", "update:contact", "delete:contact", "create:lead", "update:lead", "delete:lead", "create:company", "update:company", "delete:company", "create:deal", "update:deal", "delete:deal", "create:note", "update:note", "delete:note", "create:comment", "update:comment", "delete:comment"] }

    it "setup a subscriber" do
      Subscriber.should_receive(:new).with(nil, channels, listener.handler).and_return(stub(:listen => true))
      listener.setup_subscriber
    end
  end

  describe "catchup" do
    listener.catchup
  end
end
