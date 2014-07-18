Rails.application.routes.draw do
  resources :agreements

  resource :sessions

  resource :passwords, only: [:new, :create, :update, :show]

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/login', to: 'sessions#new', via: [:get]
  match '/logout', to: 'sessions#destroy', via: [:get]
  match '/login_failure', to: 'sessions#failure', via: [:get]
  match '/auth/failure', to: 'sessions#failure', via: [:get]


  root 'agreements#index', as: :home
end
