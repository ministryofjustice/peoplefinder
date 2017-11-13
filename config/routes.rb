Rails.application.routes.draw do
  root 'home#show', as: :home
  get 'ping', to: 'ping#index'
  get 'healthcheck', to: 'health_check#index'

  post '/report_problem', to: 'report#index'

  namespace :api, format: [:json] do
    resource :people, only: [:show]
  end

  resources :profile_photos, only: [:create]

  resources :groups, path: 'teams' do
    resources :groups, only: [:new]
    get :people, on: :member, action: 'all_people'
    get :"people-outside-subteams", on: :member, action: 'people_outside_subteams'
    get :organogram, on: :member, action: 'organogram'
  end

  resources :people do
    collection do
      get :add_membership
    end

    resource :image, controller: 'person_image', only: [:edit, :update]
    resource :email, controller: 'person_email', only: [:edit, :update]
    resources :suggestions, only: [:new, :create]
    resource :deletion_request, controller: 'person_deletion_request',
                                path: 'deletion-request',
                                only: [:new, :create]
  end

  resource :sessions, only: [:new, :create, :destroy] do
    get :unsupported_browser, on: :new
  end

  resources :tokens, only: [:create, :destroy, :show] do
    member do
      get 'unsupported_browser'
    end
  end

  match '/sessions/people', to: 'sessions#create_person', via: :post
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
    resources :team_descriptions, only: [:index]
  end

  resources :problem_reports, only: [:create]

  admin_ip_matcher = IpAddressMatcher.new(Rails.configuration.admin_ip_ranges)

  constraints ip: admin_ip_matcher do
    namespace :admin do
      root to: 'management#show', as: :home
      get 'user_behavior_report', controller: 'management', action: :user_behavior_report
      get 'generate_user_behavior_report', controller: 'management', action: :generate_user_behavior_report
      resources :person_uploads, only: [:new, :create]
    end
  end

  get '/my/profile', to: 'home#my_profile'
  get '/cookies', to: 'pages#show', id: 'cookies', as: :cookies
end
