require 'mantle'
require 'pry'
require 'sidekiq/testing'

Mantle.configure do |config|
  config.logger = Logger.new("/dev/null")
end

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end
