RefugeeConnect::Application.routes.draw do
  root :to =>   'pages#home'

  match 'users/new_tutor', to: 'users#new_tutor'
  match 'users/new_tutee', to: 'users#new_tutee'
  get 'users/cancel' => 'users#cancel'
  get 'users/match/:user_id' => 'users#match', as: :match_users
  resources :users
  resources :appointments
  post 'appointments/batch'
  
  

  post 'text_from_user/' => 'text_from_users#create'
  get 'text_from_user/:From/:Body' => 'text_from_users#create'
  post 'text_from_user/:From/:Body' => 'text_from_users#create', as: :text_from_user

  resources :sessions, only: [:new, :create, :destroy]
  resources :call_to_users
  
  
  match '/signup',  to: 'users#new'
  match '/signin',  to: 'sessions#new'
  delete '/login' => 'sessions#destroy'
  match '/signout', to: 'sessions#destroy', via: :delete
  match 'auth/:provider/callback', to: 'sessions#create_omniauth'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy'

  match ':controller(/:action(/:id(.:format)))'
  match ':controller(/:action(.:format))'
end
