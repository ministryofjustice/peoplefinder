Peoplefinder::Engine.routes.draw do
  root 'home#show', as: :home

  resources :groups, path: 'teams' do
    resources :groups, only: [:new]
    get :people, on: :member, action: 'all_people'
  end

  resources :people do
    collection do
      get :add_membership
    end
    resource :image, controller: 'person_image', only: [:edit, :update]
    resources :information_requests, only: [:new, :create]
    resources :reported_profiles, only: [:new, :create]
  end
  resources :memberships, only: [:destroy]
  resource :sessions, only: [:new, :create, :destroy]
  resources :tokens, only: [:create, :destroy, :show]

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/audit_trail', to: 'versions#index', via: [:get]
  match '/audit_trail/undo/:id', to: 'versions#undo', via: [:post]
  match '/search', to: 'search#index', via: [:get]
  match '/org.json', to: 'org#show', via: [:get]

  match '/404', to: 'errors#file_not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  get '/groups/:id', to: redirect('/teams/%{id}')
  get '/groups/:id/edit', to: redirect('/teams/%{id}/edit')
  get '/groups/:id/people', to: redirect('/teams/%{id}/people')
end
