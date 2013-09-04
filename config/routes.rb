RefugeeConnect::Application.routes.draw do

  resources :users
  root :to =>   'pages#home'
  get 'text_from_user/:From/:Body' => 'text_from_users#create'
  post 'text_from_user/:From/:Body' => 'text_from_users#create', as: :text_from_user

  resources :sessions, only: [:new, :create, :destroy]
  resources :call_to_users
  resources :appointments

  post 'appointments/batch'
  get 'users/cancel' => 'users#cancel'
  get 'users/match/:user_id' => 'users#match', as: :match_users
  match '/signup',  to: 'users#new'
  match '/signin',  to: 'sessions#new'
  delete '/login' => 'sessions#destroy'
  match '/signout', to: 'sessions#destroy', via: :delete

  match ':controller(/:action(/:id(.:format)))'
  match ':controller(/:action(.:format))'
end
