Rails.application.routes.draw do
  root 'home#show', as: :home
  get 'ping', to: 'ping#index'
  get 'healthcheck', to: 'health_check#index'

  namespace :api, format: [:json] do
    resources :people, only: [:show]
  end

  resources :profile_photos, only: [:create]

  resources :groups, path: 'teams' do
    resources :groups, only: [:new]
    get :people, on: :member, action: 'all_people'
    get :"people-outside-subteams", on: :member, action: 'people_outside_subteams'
  end

  resources :people do
    collection do
      get :add_membership
    end
    resource :image, controller: 'person_image', only: [:edit, :update]
    resources :suggestions, only: [:new, :create]
  end
  resources :memberships, only: [:destroy]
  resource :sessions, only: [:new, :create, :destroy]
  resources :tokens, only: [:create, :destroy, :show]

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/audit_trail', to: 'versions#index', via: [:get]
  match '/audit_trail/undo/:id', to: 'versions#undo', via: [:post]
  match '/search', to: 'search#index', via: [:get]

  get '/groups/:id', to: redirect('/teams/%{id}')
  get '/groups/:id/edit', to: redirect('/teams/%{id}/edit')
  get '/groups/:id/people', to: redirect('/teams/%{id}/people')

  namespace :metrics do
    resources :activations, only: [:index]
    resources :completions, only: [:index]
    resources :profiles, only: [:index]
  end

  resources :problem_reports, only: [:create]

  admin_ip_matcher = IpAddressMatcher.new(Rails.configuration.admin_ip_ranges)

  constraints ip: admin_ip_matcher do
    namespace :admin do
      resources :person_uploads, only: [:new, :create]
    end
  end

  get '/cookies', to: 'pages#show', id: 'cookies', as: :cookies
end
