Vcp::Application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks', registrations: "registrations" }
  resources :users
  # Added for Sidekiq frontend
  require 'sidekiq/web'
  require 'sidetiq/web'

  scope '/admin' do
    resources :classes, only: [:create, :destroy, :index, :update], controller: :character_classes
    resources :races,   only: [:create, :destroy, :index, :update]
    resources :zones,   only: [:create, :destroy, :index, :update]
    resources :guilds
    resources :participations, only: [:destroy, :update]
    resources :settings, only: [:index, :update]
    mount Sidekiq::Web => '/sidekiq', as: 'sidekiq'
    mount Sidekiq::Monitor::Engine => '/sidekiqmonitor'
  end

  resources :characters
  match '/characters/:id',              to: 'characters#claim',         via: 'post'
  #match '/characters/:id/addstanding',  to: 'characters#add_standing',  via: 'post',  as: 'add_standing_character'
  match '/characters/:id/history',      to: 'characters#history',       via: 'get',   as: 'character_history'
  match '/characters/:id/sync',         to: 'characters#sync',          via: 'post',  as: 'sync_character'
  match '/characters/:id/unclaim',      to: 'characters#unclaim',       via: 'post',  as: 'unclaim_character'

  resources :standings
  match '/standings/:id/retire',              to: 'standings#retire',           via: 'post',  as: 'retire_standing'
  match '/standings/:id/resume',              to: 'standings#resume',           via: 'post',  as: 'resume_standing'
  match '/standings/:id/list_characters',     to: 'standings#list_characters',  via: 'get',   as: 'list_characters'
  match '/standings/:id/transfer/:character',        to: 'standings#transfer',         via: 'post',  as: 'transfer_standing'
  resources :raids

  root 'static_pages#home'
  match '/about',         to: 'static_pages#about',   via: 'get'
  match '/contact',       to: 'static_pages#contact', via: 'get'
  match '/help',          to: 'static_pages#help',    via: 'get'

  match '/users/:id/ghost', to: 'users#ghost', via: 'get', as: 'ghost_user'

  # get '/auth/:provider/callback' => 'omniauth#callback'
  # get '/auth/failure' => 'omniauth#failure'
  # get '/doit' => 'omniauth#signin'

  # match '/users/sign_in', to: 'sessions#new',         via: 'get'
  # match '/signout',       to: 'sessions#destroy',     via: 'delete'
  # match '/signup',        to: 'users#new',            via: 'get'

end
