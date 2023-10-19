Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root to: redirect('/orders')

  get    'login',  to: 'sessions#new', as: 'login'
  post   'login',  to: 'sessions#create'
  get    'logout', to: 'sessions#destroy', as: 'logout'
  delete 'logout', to: 'sessions#destroy'

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :orders, only: :create
    end
    namespace :v2 do
      resources :orders, only: :create
    end
    namespace :v3 do
      resources :orders, only: :create
    end
    namespace :v4 do
      resources :orders, only: :create
    end
  end

  scope :autocomplete, as: :autocomplete do
    get :customers, to: 'autocomplete#customers'
    get :drives, to: 'autocomplete#drives'
  end

  resources :csv_files, path: 'csv', only: %i[create index show]

  get 'help', to: 'help#index', as: 'helps'
  get 'help/*page', to: 'help#show', as: 'help'

  resources :orders, except: [:destroy] do
    collection do
      get 'mine', as: 'my'
    end
    resource :day_count, defaults: { format: 'json' }, only: :show
    resource :state, only: :create
    resources :users, only: %i[create destroy]
  end

  resources :passwords, except: :delete

  resources :reports do
    collection do
      post :preview
    end

    member do
      get :run
    end
  end

  resources :users, except: :destroy do
    resource :roles, only: %i[edit update]
    member do
      patch :disable
    end
  end
end
