Rails.application.routes.draw do
  root "home#index"

  resource :sessions

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
end
