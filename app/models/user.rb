class User < ActiveRecord::Base
  # You likely have this before callback set up for the token.
  before_save :ensure_authentication_token!

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :user_friendships

  has_many :friends,
  through: :user_friendships,
  :conditions => "accepted = 2"

  has_many :invited_friends,
  through: :user_friendships,
  :conditions => "accepted = 0"

  has_many :inviting_friends,
  through: :user_friendships,
  :conditions => "accepted = 1"

  validates_presence_of :name

  def ensure_authentication_token!
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def reset_authentication_token!
    self.authentication_token = generate_authentication_token
    save
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
