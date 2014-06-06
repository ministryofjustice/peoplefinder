ParliamentaryQuestions::Application.routes.draw do

  resources :watchlist_members

  resources :action_officers

  devise_for :users

  resources :users
  resources :pqs  
  get 'pqs/commission/:id' => 'pqs#commission'
  post 'pqs/assign/:id' => 'pqs#assign'

  get '/', to: 'dashboard#index', as: :root
  get 'dashboard' => 'dashboard#index'

  get 'filter' => 'filter#index'
  get 'filter/:search' => 'filter#index'
  get 'dashboard/search' => 'dashboard#search'
  post 'dashboard/search/:search' => 'dashboard#search'
  
  get 'assignment/:uin' => 'assignment#index'
  post 'assignment/:uin' => 'assignment#action'

end
