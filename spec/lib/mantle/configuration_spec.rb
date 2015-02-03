require 'spec_helper'

describe Mantle::Configuration do
  it 'can set/get message_bus_channels' do
    config = Mantle::Configuration.new
    config.message_bus_channels = ["update"]
    expect(config.message_bus_channels).to eq(Array("update"))
  end

  it 'sets default message_bus_channels' do
    config = Mantle::Configuration.new
    expect(config.message_bus_channels).to eq([])
  end

  it 'can set/get message_bus_redis' do
    redis = double("redis")
    config = Mantle::Configuration.new
    config.message_bus_channels = redis
    expect(config.message_bus_channels).to eq(redis)
  end

  it 'can set/get message_bus_catch_up_key_name' do
    config = Mantle::Configuration.new
    config.message_bus_catch_up_key_name = "party"
    expect(config.message_bus_catch_up_key_name).to eq("party")
  end

  it 'can set/get message_handler' do
    config = Mantle::Configuration.new
    config.message_handler = FakeHandler
    expect(config.message_handler).to eq(FakeHandler)
  end

  it 'configures default message handler' do
    config = Mantle::Configuration.new
    expect(config.message_handler).to eq(Mantle::MessageHandler)
  end

  FakeHandler = Class.new
end


