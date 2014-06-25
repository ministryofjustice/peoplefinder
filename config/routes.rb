Rails.application.routes.draw do
  root 'welcome#index'

  resources :groups do
    resources :groups, only: [:new]
    resources :memberships, controller: 'group_memberships'
  end
  resources :people do
    resources :memberships, controller: 'person_memberships'
  end
  resources :memberships
  resource :sessions

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/audit_trail', to: 'audits#index', via: [:get]
  match '/search', to: 'people#search', via: [:get]
end
