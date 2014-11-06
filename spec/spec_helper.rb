require 'mantle'
require 'pry'
require 'sidekiq/testing'

Mantle.logger = Logger.new("/dev/null")

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end
