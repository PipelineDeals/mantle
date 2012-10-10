require 'sidekiq/web'

AmazonSearch::Application.routes.draw do
  get 'search', to: 'search#index'

  mount Sidekiq::Web, at: '/sidekiq'
end
