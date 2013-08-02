require 'mantle'
require 'sidekiq'

Mantle.boot_system!

require 'sidekiq/web'
run Sidekiq::Web
