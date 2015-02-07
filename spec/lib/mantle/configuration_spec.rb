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

  it 'can set/get message_handler' do
    FakeHandler = Class.new

    config = Mantle::Configuration.new
    config.message_handler = FakeHandler
    expect(config.message_handler).to eq(FakeHandler)
  end

  it 'configures default message handler' do
    config = Mantle::Configuration.new
    expect(config.message_handler).to eq(Mantle::MessageHandler)
  end

  it 'can set/get logger' do
    logger = Logger.new(STDOUT)
    config = Mantle::Configuration.new
    config.logger = logger
    expect(config.logger).to eq(logger)
  end

  it 'configures default logger' do
    config = Mantle::Configuration.new
    expect(config.logger.level).to eq(1)
  end
end


