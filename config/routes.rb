Rails.application.routes.draw do  
  post 'register', to: 'users#create'
  post 'login', to: 'authentication#login'
  get 'logout', to: 'authentication#logout'
  put 'update', to: 'users#update'
  delete 'delete', to: 'users#destroy'
  resources :users, :except => [:create, :update]
  resources :applications, param: :app_token do 
    resources :chats, param: :number do
      member do
        post :add_users
      end
      resources :messages, param: :number
      member do
        get :search
      end
    end  
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
