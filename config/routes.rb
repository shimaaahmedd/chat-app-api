Rails.application.routes.draw do
  
  post 'register', to: 'users#create'
  post 'login', to: 'authentication#login'
  get 'logout', to: 'authentication#logout'
  resources :user, :except => [:create]
  resources :applications, param: :app_token do 
    resources :chats
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
