Rails.application.routes.draw do
  root 'home#show', as: :home

  resources :groups do
    resources :groups, only: [:new]
    get :people, on: :member, action: 'all_people'
  end

  get '/teams', to: 'groups#show', id: ''
  get '/teams/*id', to: 'groups#show'

  resources :people do
    collection do
      get :add_membership
    end
    resource :image, controller: 'person_image'
  end
  resources :memberships, only: [:destroy]
  resource :sessions

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/audit_trail', to: 'versions#index', via: [:get]
  match '/audit_trail/undo/:id', to: 'versions#undo', via: [:post]
  match '/search', to: 'people#search', via: [:get]
  match '/org.json', to: 'org#show', via: [:get]

  match '/404', to: 'errors#file_not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
