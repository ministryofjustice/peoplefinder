Rails.application.routes.draw do
  resources :agreements

  resource :sessions

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]

  root 'agreements#index', as: :home
end
