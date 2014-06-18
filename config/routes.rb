Rails.application.routes.draw do
  resource :sessions
  post '/auth/:provider/callback', to: 'sessions#create'
  root 'welcome#index'

  resources :groups
end
