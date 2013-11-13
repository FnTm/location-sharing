class UserFriendshipsController < ApplicationController
  before_filter :confirm_logged_in

  def create
    params[:user_friendship][:user_id] = current_user.id
    binding.pry
    @user_friendship = UserFriendship.new(user_friendship_params)
    if @user_friendship.save
      redirect_to root_url, :notice => "Friend added!"
    else
      redirect_to request.env["HTTP_REFERER"]
      flash[:error] = @user_friendship.errors.full_messages
    end
  end

  def delete
    user_friendship = UserFriendship.find(params[:id])
    if current_user.user_friendships.include? user_friendship
      user_friendship.destroy
      flash[:notice] = "Friendship successfully deleted."
    else
      flash[:error] = "You are not authorized to delete this friendship."
    end
  end

  private
  def user_friendship_params
    params.require(:user_friendship).permit(:friend_email, :user_id, :friend_id)
  end
end
