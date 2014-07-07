Rails.application.routes.draw do
  root 'groups#index', as: :home

  resources :groups do
    resources :groups, only: [:new]
    resources :memberships, controller: 'group_memberships'
  end
  resources :people do
    collection do
      get :add_membership
    end
    resources :memberships, controller: 'person_memberships'
    resource :image, controller: 'person_image'
  end
  resource :sessions

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/audit_trail', to: 'audits#index', via: [:get]
  match '/search', to: 'people#search', via: [:get]
end
