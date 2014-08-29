Rails.application.routes.draw do
  get "/go/:id", to: "tokens#show", as: :token

  resources :reviews
  resources :feedback_requests, only: [:update]
  resources :submissions, only: [:index, :edit, :update]
  resources :reminders, only: [:create]

  resources :users, only: [:index] do
    resources :reviews
  end
end
