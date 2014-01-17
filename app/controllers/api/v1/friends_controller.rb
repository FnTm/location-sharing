class API::V1::FriendsController < ApplicationController
  respond_to :json

  include ApplicationHelper
  include DeviseHelper
  before_filter :authenticate_user_from_token!

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  def create
    if UserFriendship.request current_user, User.find_by_email(params[:email])
      render :json => {success: true}
    else
      render :status => "401", :json => {success: false}
    end
  end

  def update
    if UserFriendship.accept current_user, User.find_by_id(params[:id])
      render :json => {success: true}
    else
      render :status => "401", :json => {success: false}
    end
  end

  def destroy
    if UserFriendship.reject current_user, User.find_by_id(params[:id])
      render :json => {success: true}
    else
      render :status => "401", :json => {success: false}
    end
    #should delete friendship
  end

  def index
    friends = current_user.friends.as_json(only: [:id, :name, :email, :latitude, :longitude])
    invited_friends = current_user.invited_friends.as_json(only: [:id, :name, :email])
    inviting_friends = current_user.inviting_friends.as_json(only: [:id, :name, :email])
    render :json => {:friends => friends, :invited_friends => invited_friends, :inviting_friends => inviting_friends}
  end

  def show
    friend = User.find_by_id(params[:id])
    if current_user.friends.find_by_id friend
      render :json => friend.as_json(only: [:id, :name, :email, :latitude, :longitude])
    elsif current_user.invited_friends.find_by_id friend or
        current_user.inviting_friends.find_by_id friend
      render :json => friend.as_json(only: [:id, :name, :email])
    else
      render :status => "401", :json => {success: false}
    end
  end
end
