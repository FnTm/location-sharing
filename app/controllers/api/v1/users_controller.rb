class API::V1::UsersController < ApplicationController
  respond_to :json
  def index
    @user = Users.find 1
    respond_with @user
  end
end
