Rails.application.routes.draw do
  resources :agreements

  resource :sessions

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/login', to: 'sessions#new', via: [:get]
  match '/logout', to: 'sessions#destroy', via: [:get]
  match '/auth/failure', to: 'sessions#new', via: [:get]

  root 'agreements#index', as: :home
end
