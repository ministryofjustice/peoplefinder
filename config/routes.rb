Rails.application.routes.draw do
  resource :sessions
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  root 'welcome#index'

  resources :groups, :people
end
