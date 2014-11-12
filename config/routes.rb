Vcp::Application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks', registrations: "registrations" }
  resources :users
  # Added for Sidekiq frontend
  require 'sidekiq/web'
  require 'sidetiq/web'

  scope '/admin' do
    resources :classes,   only: [:create, :destroy, :index, :update], controller: :character_classes
    match '/classes/sync',  to: 'character_classes#sync', via: 'post',  as: 'sync_classes'
    resources :races,     only: [:create, :destroy, :index, :update]
    match '/races/sync',  to: 'races#sync', via: 'post',  as: 'sync_races'
    resources :zones,   only: [:create, :destroy, :index, :update]
    resources :guilds
    resources :participations, only: [:destroy, :update]
    match '/admin/participations/:id/duplicate', to: 'participations#duplicate', via: 'post', as: 'duplicate_participation'
    mount Sidekiq::Web => '/sidekiq', as: 'sidekiq'
    mount Sidekiq::Monitor::Engine => '/sidekiqmonitor'
    #mount Sidetiq::Web => '/sidekiq/sidetiq'
  end

  resources :characters
  match '/characters/:id',                to: 'characters#claim',           via: 'post'
  match '/characters/:id/history',        to: 'characters#history',         via: 'get',   as: 'character_history'
  match '/characters/:id/sync',           to: 'characters#sync',            via: 'post',  as: 'sync_character'
  match '/characters/:id/unclaim',        to: 'characters#unclaim',         via: 'post',  as: 'unclaim_character'
  match '/characters/:id/add_to_standing',to: 'characters#add_to_standing', via: 'patch',  as: 'add_to_standing'

  resources :standings
  match '/standings/:id/retire',              to: 'standings#retire',           via: 'post',  as: 'retire_standing'
  match '/standings/:id/resume',              to: 'standings#resume',           via: 'post',  as: 'resume_standing'
  match '/standings/:id/list_characters',     to: 'standings#list_characters',  via: 'get',   as: 'list_characters'
  match '/standings/:id/transfer/:character',        to: 'standings#transfer',         via: 'post',  as: 'transfer_standing'
  resources :raids

  root 'static_pages#home'
  match '/about',         to: 'static_pages#about',   via: 'get'
  match '/contact',       to: 'static_pages#contact', via: 'get'

  match '/users/:id/ghost', to: 'users#ghost', via: 'get', as: 'ghost_user'

  match '/users/:id/toggle_role/:role_id', to: 'users#toggle_role', via: 'post', as: 'user_toggle_role'

  # Help
  match '/help', to: 'high_voltage/pages#show', via: 'get', id: 'index'
  match '/help/registration', to: 'high_voltage/pages#show', via: 'get', id: 'registration'
  match '/help/user_profile', to: 'high_voltage/pages#show', via: 'get', id: 'user_profile'

end
