Rails.application.routes.draw do
  resources :agreements
  resources :responsibilities_agreements
  resources :objectives_agreements

  resource :sessions

  resource :passwords, only: [:new, :create, :update, :show]
  resource :registration, only: [:new, :update]

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/login', to: 'sessions#new', via: [:get]
  match '/logout', to: 'sessions#destroy', via: [:get]
  match '/auth/failure', to: 'sessions#new', via: [:get], failed: true

  root 'agreements#index', as: :home
end
