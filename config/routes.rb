Rails.application.routes.draw do
  root "home#index"

  resource :dashboard, only: [:show]

  get "/go/:token", to: "tokens#show"
end
