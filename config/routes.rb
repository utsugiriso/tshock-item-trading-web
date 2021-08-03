Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'top#index'

  post 'login', to: 'sessions#create'
  delete  'logout', to: 'sessions#destroy'

  resources :server_statuses, only: :show
  resources :selling_items, only: [:index]
  resources :items, only: [:index]

  namespace :my do
    resources :items, only: :index
    resources :selling_items, only: [:index, :new, :create, :destroy]
    resources :purchased_items, only: [:index, :new, :create]
    resources :purchase_requests, only: [:index, :new, :create, :destroy]
  end
end
