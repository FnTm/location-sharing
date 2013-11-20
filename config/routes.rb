FindMyFriends::Application.routes.draw do
  devise_for :users
  root :to => "home#index"

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      resources :users
    end
  end
end
