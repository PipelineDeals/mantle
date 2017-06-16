require 'spec_helper'

describe Mantle::Configuration do
  it 'can set/get message_bus_redis' do
    redis = double("redis")
    config = Mantle::Configuration.new
    config.message_bus_redis = redis
    expect(config.message_bus_redis).to eq(redis)
  end

  it 'can set/get message_handlers' do
    config = Mantle::Configuration.new
    config.message_handlers = {'a_channel' => 'FakeHandler'}
    expect(config.message_handlers).to eq({'a_channel' => 'FakeHandler'})
  end

  it 'can set/get whoami' do
    config = Mantle::Configuration.new
    config.whoami = 'SantaClaus'
    expect(config.whoami).to eq('SantaClaus')
  end

  it 'configures default message handler' do
    config = Mantle::Configuration.new
    expect(config.message_handlers).to be_instance_of(Mantle::MessageHandlers)
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

  it 'can set/get namespace for local redis listen' do
    config = Mantle::Configuration.new
    config.redis_namespace = "fake"
    expect(config.redis_namespace).to eq("fake")
  end

  it 'configures default redis namespace' do
    config = Mantle::Configuration.new
    expect(config.redis_namespace).to eq(nil)
  end
end
