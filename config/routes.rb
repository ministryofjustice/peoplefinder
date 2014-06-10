ParliamentaryQuestions::Application.routes.draw do

  resources :watchlist_members

  resources :action_officers

  devise_for :users

  resources :users
  resources :pqs  
  get 'commission/:id' => 'commission#commission'
  post 'assign/:id' => 'commission#assign'

  get '/', to: 'dashboard#index', as: :root
  get 'dashboard' => 'dashboard#index'

  get 'filter' => 'filter#index'
  get 'filter/:search' => 'filter#index'
  get 'dashboard/search' => 'dashboard#search'
  post 'dashboard/search/:search' => 'dashboard#search'
  
  get 'assignment/:uin' => 'assignment#index'
  post 'assignment/:uin' => 'assignment#action'

  get 'watchlist/dashboard' => 'watchlist_dashboard#index'
  get 'watchlist/send_emails' => 'watchlist_send_emails#send_emails'

end
