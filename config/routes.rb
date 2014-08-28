Rails.application.routes.draw do
  root "home#index"

  resource :dashboard, only: [:show]

  get "/go/:id", to: "tokens#show", as: :token

  resources :reviews
  resources :acceptances, only: [:edit, :update]
  resources :submissions, only: [:index, :edit, :update]

  resources :users, only: [:index] do
    resources :reviews
  end
end
