class UsersController < ApplicationController
  before_filter :confirm_logged_in, :except => [:new, :create]
  def new
      @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_url, :notice => "Signed up!"
    else
      flash[:error] = @user.errors.full_messages
    end
  end

  def index
    @user_friendship = UserFriendship.new
    @friends = current_user.friends
    @friendships = current_user.user_friendships
    # @devices = current_user.devices
  end


  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
