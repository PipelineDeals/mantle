require 'sidekiq/web'

Mantle.boot_system!

Mantle::Monitor = Sidekiq::Web
