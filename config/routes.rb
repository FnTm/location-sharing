FindMyFriends::Application.routes.draw do
  devise_for :users

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      as :user do
        post '/users/', to: 'registrations#create'
        delete '/users/:id', to: 'registrations#destroy'
        put '/users/:id', to: 'registrations#update'
        get '/users/:id', to: 'registrations#show'
        put '/users/:id/location', to: 'registrations#update_location'
      end
      as :session do
        post '/sessions/', to: 'sessions#create'
        delete '/sessions/', to: 'sessions#destroy'
      end
    end
  end
end
