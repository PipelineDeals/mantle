require_relative './lib/mantle'
require 'sidekiq'

Mantle.boot_system!

require 'sidekiq/web'
run Sidekiq::Web
