Rails.application.routes.draw do
  root "home#index"

  get "/go/:id", to: "tokens#show", as: :token

  resources :reviews
  resources :replies, only: [:index]
  resources :invitations, only: [:update]
  resources :submissions, only: [:edit, :update]
  resources :reminders, only: [:create]

  resources :users, only: [:index, :show] do
    resources :reviews
  end

  namespace :results do
    resources :reviews, only: [:index]
    resources :users, only: [:index] do
      resources :reviews, only: [:index]
    end
  end

  %i[ leadership_model moj_story ].each do |page|
    get page.to_s.gsub(/_/, '-'), to: 'pages#show', id: page, as: page
  end
end
