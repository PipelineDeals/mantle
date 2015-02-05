require 'mantle'
require 'pry'
require 'sidekiq/testing'


RSpec.configure do |config|
  config.before(:each) do
    Mantle.configure
    Sidekiq::Worker.clear_all
  end
end
