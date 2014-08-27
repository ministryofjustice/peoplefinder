Rails.application.routes.draw do
  root "home#index"

  resource :dashboard, only: [:show]

  get "/go/:id", to: "tokens#show", as: :token

  resources :reviews

  resources :users, only: [] do
    resources :reviews
  end
end
