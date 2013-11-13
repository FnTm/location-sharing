class UserFriendship < ActiveRecord::Base

  attr_accessor :friend_email

  before_validation :get_friend_id

  belongs_to :user
  belongs_to :friend, class_name: "User", foreign_key: "friend_id"

  validates_presence_of :friend_id, :user_id
  validate :not_friendship_to_self
  validate :relationship_uniqueness
  def get_friend_id
    if friend_email.present?
      self.friend_id = User.find_by_email(friend_email).id
    end
  end

  def relationship_uniqueness
    existing_record = UserFriendship.find(:first, :conditions => ["(user_id = ? and friend_id = ?) or (user_id = ? and friend_id = ?)", user_id, friend_id, friend_id, user_id])
    unless existing_record.blank?
      errors.add(:friend_id, "Friendship already exists.")
    end
  end

  def not_friendship_to_self
    unless user_id != friend_id
      errors.add(:user_id, "cannot add self to friends.")
    end
  end
end
