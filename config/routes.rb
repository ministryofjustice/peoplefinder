Rails.application.routes.draw do
  root 'welcome#index'

  resources :groups
  resources :people
  resources :memberships
  resource :sessions

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
end
