RefugeeConnect::Application.routes.draw do
  root :to =>   'pages#home'

  match 'users/new_tutor', to: 'users#new_tutor'
  match 'users/new_tutee', to: 'users#new_tutee'
  get 'users/cancel' => 'users#cancel'
  
  resources :users

  resources :specific_openings, path: 'sos' do
    resources :confirmations, path: 'cos'
  end

  resources :appointments
  resources :lessons
  resources :assignments
  resources :user_assignments
  resources :profile_infos
  put 'profile_infos/:id', to: 'profile_infos#update'


  resources :matches
  resources :bookpages
  post 'user_assignments/assign/:assignment_id', to: 'user_assignments#assign'

  post 'appointments/batch'
  mount Attachinary::Engine => "/attachinary"
  resources :comments
  get 'admin', to: 'pages#admin'
  
  

  post 'text_from_user/' => 'text_from_users#create'
  get 'text_from_user/:From/:Body' => 'text_from_users#create'
  post 'text_from_user/:From/:Body' => 'text_from_users#create', as: :text_from_user

  resources :sessions, only: [:new, :create, :destroy]
  resources :call_to_users
  resources :openings
  
  
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
