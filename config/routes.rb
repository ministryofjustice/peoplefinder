ParliamentaryQuestions::Application.routes.draw do

  resources :press_desks

  resources :press_officers

  resources :progresses

  resources :ministers

  resources :deputy_directors

  resources :divisions

  resources :directorates

  resources :watchlist_members

  resources :action_officers

  devise_for :users

  resources :users
  resources :pqs  


  get 'admin' => 'admin#index'

  get 'commission/:id' => 'commission#commission'
  post 'assign/:id' => 'commission#assign'

  get '/', to: 'dashboard#index', as: :root
  get 'dashboard' => 'dashboard#index'
  get 'dashboard/in_progress' => 'dashboard#in_progress'

  get 'filter' => 'filter#index'
  get 'filter/:search' => 'filter#index'
  get 'dashboard/search' => 'dashboard#search'
  post 'dashboard/search/:search' => 'dashboard#search'

  get 'dashboard/by_status/:qstatus' => 'dashboard#by_status'
  
  get 'assignment/:uin' => 'assignment#index'
  post 'assignment/:uin' => 'assignment#action'

  get 'watchlist/dashboard' => 'watchlist_dashboard#index'
  get 'watchlist/send_emails' => 'watchlist_send_emails#send_emails'
  get 'find_action_officers' => 'action_officers#find'
end
