require 'spec_helper'

include Devise::TestHelpers

describe UserFriendship do
  it {should belong_to(:user)}
  it {should belong_to(:friend)}

  before :each do
    @credentials1 = {:name => "Klāvs", :email => "Klavs@taube.com", :password => "passwoord", :password_confirmation => "passwoord"}
    @credentials2 = {:name => "Jānis", :email => "Janis@merce.com", :password => "passwoord", :password_confirmation => "passwoord"}
    @user1 = FactoryGirl.create(:user, @credentials1)
    @user2 = FactoryGirl.create(:user, @credentials2)
  end

  describe "Friend request" do
    it "should request friend" do
      UserFriendship.request @user1, @user2
      @user1.reload
      @user2.reload
      @user1.invited_friends.should include(@user2)
      @user2.inviting_friends.should include(@user1)
      @user1.friends.should_not include(@user2)
      @user2.friends.should_not include(@user1)
    end

    it "should not invite self" do
      UserFriendship.request @user1, @user2
      @user1.reload
      @user1.invited_friends.should_not include(@user1)
      @user1.inviting_friends.should_not include(@user1)
      @user1.friends.should_not include (@user1)
    end
  end
  describe "Friendship accept" do
    it "should accept friendship" do
      UserFriendship.request @user1, @user2
      UserFriendship.accept @user2, @user1
      @user1.reload
      @user2.reload
      @user1.invited_friends.should_not include(@user2)
      @user2.inviting_friends.should_not include(@user1)
      @user1.friends.should include(@user2)
      @user2.friends.should include(@user1)
    end

    it "inviter should not be able to accept friendship" do
      UserFriendship.request @user1, @user2
      UserFriendship.accept @user1, @user2
      @user1.reload
      @user2.reload
      @user1.friends.should_not include(@user2)
      @user2.friends.should_not include(@user1)
    end

    it "should not request friendship twice" do
      UserFriendship.request @user1, @user2
      UserFriendship.request @user1, @user2
      @user1.reload
      @user2.reload
      @user1.invited_friends.length.should eq(1)
      @user2.inviting_friends.length.should eq(1)
      UserFriendship.all.length.should eq(2)
    end

    it "should not request friendship to inviting friend." do
      UserFriendship.request @user1, @user2
      UserFriendship.request @user2, @user1
      @user1.reload
      @user2.reload
      @user1.invited_friends.length.should eq(1)
      @user2.inviting_friends.length.should eq(1)
      @user2.invited_friends.should_not include(@user1)
      @user1.inviting_friends.should_not include(@user2)
      UserFriendship.all.length.should eq(2)
    end
  end
end
