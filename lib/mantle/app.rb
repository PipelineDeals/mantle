Mantle.boot_system!
require 'sidekiq/web'
Mantle::App = Sidekiq::Web

