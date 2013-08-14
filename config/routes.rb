RefugeeConnect::Application.routes.draw do

  resources :users
  root :to =>   'pages#home'
  resources :sessions, only: [:new, :create, :destroy]
  resources :call_to_users
  get 'users/cancel' => 'users#cancel'
  match '/signup',  to: 'users#new'
  match '/signin',  to: 'sessions#new'
  delete '/login' => 'sessions#destroy'
  match '/signout', to: 'sessions#destroy', via: :delete

  match ':controller(/:action(/:id(.:format)))'
  match ':controller(/:action(.:format))'
end
