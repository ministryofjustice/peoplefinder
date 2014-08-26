Rails.application.routes.draw do
  root "home#index"

  resource :dashboard, only: [:show]

  get "/go/:id", to: "tokens#show", as: :token
end
