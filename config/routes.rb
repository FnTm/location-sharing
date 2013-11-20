FindMyFriends::Application.routes.draw do

  devise_for :users
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "users#new", :as => "sign_up"
  get "create_user_friendship" => "user_friendships#create", :as => "create_user_friendship"
  root :to => "users#index"

  resources :users
  resources :sessions
  resources :user_friendships
end
