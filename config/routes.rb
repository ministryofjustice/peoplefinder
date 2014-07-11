Rails.application.routes.draw do
  resources :agreements

  root "home#index"

  resource :sessions

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]

  resource :jobholder, only: [] do
    resources :agreements, scope: :jobholder
  end

  resource :manager, only: [] do
    resources :agreements, scope: :manager
  end
end
