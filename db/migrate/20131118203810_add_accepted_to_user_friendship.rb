class AddAcceptedToUserFriendship < ActiveRecord::Migration
  def change
    add_column :user_friendships, :accepted, :integer
  end
end
