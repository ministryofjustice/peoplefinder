Rails.application.routes.draw do
  root "home#index"

  get "/go/:id", to: "tokens#show", as: :token

  resource :login, only: [:new, :create, :destroy]

  namespace :admin do
    get "/", to: "home#index"
    resources :user_uploads, only: [:create]
    resources :users
    resources :settings, only: [:update]
    resources :introductory_mailings, only: [:create]
    resources :closure_mailings, only: [:create]
    resource :password_reset, only: [:new]
  end

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
