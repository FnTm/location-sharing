require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many(:user_friendships)
  should have_many(:friends)
  # test "the truth" do
  #   assert true
  # end
  test "no error is raised when trying to access a friend list" do
    assert_nothing_raised do
      users(:jason).friends
    end
  end
end
