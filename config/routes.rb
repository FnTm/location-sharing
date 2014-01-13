FindMyFriends::Application.routes.draw do
  devise_for :users

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      devise_for :users
    end
  end
end
