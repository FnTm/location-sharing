FindMyFriends::Application.routes.draw do
  devise_for :users, :controllers =>
    {
    :sessions => "api/v1/sessions",
    :registrations => "api/v1/registrations",
    :confirmations => "confirmations"
  }
  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      as :user do
        post '/users/', to: 'registrations#create'
        delete '/users/:id', to: 'registrations#destroy'
        put '/users/:id', to: 'registrations#update'
        get '/users/:id', to: 'registrations#show'
        post '/users/:id/location', to: 'registrations#update_location'

        post '/users/:id/confirmation', to: 'registrations#confirm_user'
        get '/users/:id/confirmation', to: 'registrations#resend_confirmation_instructions'

        post '/sessions/', to: 'sessions#create'
        delete '/sessions/', to: 'sessions#destroy'

        get '/friends/', to: 'friends#index'
        get '/friends/:id', to: 'friends#show'
        post '/friends/', to: 'friends#create'
        delete '/friends/:id', to: 'friends#destroy'
        put '/friends/:id', to: 'friends#update'
      end
    end
  end
end
