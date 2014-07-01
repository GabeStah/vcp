Vcp::Application.routes.draw do
  # Added for Sidekiq frontend
  require 'sidekiq/web'

  scope '/admin' do
    resources :classes, only: [:create, :destroy, :index, :update], controller: :character_classes
    resources :guilds
    resources :races, only: [:create, :destroy, :index, :update]
    resources :settings, only: [:index, :update]
    mount Sidekiq::Web => '/sidekiq', as: 'sidekiq'
  end
  # characters      GET    /characters(.:format)            characters#index
  #                 POST   /characters(.:format)            characters#create
  # new_character   GET    /characters/new(.:format)        characters#new
  # edit_character  GET    /characters/:id/edit(.:format)   characters#edit
  # character       GET    /characters/:id(.:format)        characters#show
  #                 PATCH  /characters/:id(.:format)        characters#update
  #                 PUT    /characters/:id(.:format)        characters#update
  #                 DELETE /characters/:id(.:format)        characters#destroy

  # match '/characters/:region/:realm/:name',      to: 'characters#show',     via: 'get',   as: 'character'
  # match '/characters/:region/:realm/:name',      to: 'characters#destroy',  via: 'delete'
  # match '/characters/:region/:realm/:name',      to: 'characters#update',   via: 'patch'
  # match '/characters/:region/:realm/:name',      to: 'characters#update',   via: 'put'
  # match '/characters/:region/:realm/:name/edit', to: 'characters#edit',     via: 'get',   as: 'edit_character'
  #
  # resources :characters, except: [:destroy, :edit, :show, :update]

  resources :characters

  resources :sessions, only: [:new, :create, :destroy]
  resources :users

  root 'static_pages#home'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  match '/signup',  to: 'users#new',            via: 'get'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
