ParliamentaryQuestions::Application.routes.draw do
  devise_for :users

  resources :users

  get '/', to: 'dashboard#index', as: :root
  get 'dashboard' => 'dashboard#index'
  get 'dashboard/detail/:uin' => 'dashboard#detail'

  get 'filter' => 'filter#index'
  get 'filter/:search' => 'filter#index'
  get 'dashboard/search' => 'dashboard#search'
  post 'dashboard/search/:search' => 'dashboard#search'

end
