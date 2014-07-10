Rails.application.routes.draw do
  root 'groups#index', as: :home

  resources :groups do
    collection do
      get :add_membership
    end
    resources :groups, only: [:new]
  end
  resources :people do
    collection do
      get :add_membership
    end
    resource :image, controller: 'person_image'
  end
  resources :memberships, only: [:destroy]
  resource :sessions

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/audit_trail', to: 'audits#index', via: [:get]
  match '/search', to: 'people#search', via: [:get]
end
