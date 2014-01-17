require 'spec_helper'

describe API::V1::FriendsController do
  before :each do
    @credentials = {:email => 'asd@def.com', :password => 'password', :password_confirmation => 'password'}
  end

  describe "Show friends" do
    #code goes here
  end

  describe "Invite friends" do
    it "should invite friend" do
      @user1 = User.new @credentials
      @credentials[:email] = 'asdd@def.com'
      @user2 = User.new @credentials
      @credentials[:email] = 'asddd@def.com'
      @user3 = User.new @credentials
      @user1.save!
      @user2.save!
      @user3.save!
      post :create, :email => @user2.email, :authentication_token => @user1.authentication_token, :format => :json
      JSON.parse(response.body)["success"].should eq(true)
      @user1.reload
      @user2.reload
      @user1.invited_friends.should include(@user2)
      @user2.inviting_friends.should include(@user1)
      (@user3.inviting_friends & [@user1, @user2]).should eq([])
      (@user3.invited_friends & [@user1, @user2]).should eq([])
    end

    it "should not invite friend if auth token is not passed" do
      @user1 = User.new @credentials
      @credentials[:email] = 'asdd@def.com'
      @user2 = User.new @credentials
      @user1.save!
      @user2.save!
      post :create, :email => @user2.email, :fromat => :json
      response.code.should eq("401")
    end
  end
  describe "" do
    before :each do
      @user1 = User.new @credentials
      @credentials[:email] = "asdd@def.com"
      @user2 = User.new @credentials
      @user1.save!
      @user2.save!
      UserFriendship.request @user1, @user2
    end

    it "should accept friendship if invited friend updates it" do
      put :update, :id => @user1.id, :authentication_token => @user2.authentication_token, :format => :json
      response.code.should eq("200")
      @user1.reload
      @user2.reload
      @user1.friends.should include(@user2)
      @user2.friends.should include(@user1)
      @user1.invited_friends.should_not include(@user2)
      @user2.inviting_friends.should_not include(@user1)
    end

    it "should not accept friendship if inviting friend updates it" do
      put :update, :id => @user2.id, :authentication_token => @user1.authentication_token
      response.code.should eq("401")
      @user1.reload
      @user2.reload
      @user1.friends.should_not include(@user2)
      @user2.friends.should_not include(@user1)
      @user1.invited_friends.should include(@user2)
      @user2.inviting_friends.should include(@user1)
    end

    it "should not accept friendship if no auth token is passed" do
      put :update, :id => @user2.id, :fromat => :json
      response.code.should eq("401")
    end

    describe "" do
      before :each do
        @credentials[:email] = 'asddd@def.com'
        @user3 = User.new @credentials
        @credentials[:email] = 'asdddd@def.com'
        @user4 = User.new @credentials
        @user3.save!
        @user4.save!
        UserFriendship.request @user3, @user1
        UserFriendship.accept @user2, @user1
        UserFriendship.request @user1, @user4
        @user1.reload
        @user2.reload
        @user3.reload
        @user4.reload
      end

      it "should show all friends" do
        get :index, :authentication_token => @user1.authentication_token, :format => :json
        response.code.should eq("200")
        body = JSON.parse(response.body)
        body["friends"][0].should have_key("latitude")
        body["friends"][0].should have_key("longitude")
        body["friends"][0]["id"].should eq(@user2.id)

        body["invited_friends"][0].should_not have_key("latitude")
        body["invited_friends"][0].should_not have_key("longitude")
        body["invited_friends"][0]["id"].should eq(@user4.id)

        body["inviting_friends"][0].should_not have_key("latitude")
        body["inviting_friends"][0].should_not have_key("longitude")
        body["inviting_friends"][0]["id"].should eq(@user3.id)
      end

      it "should show one friend" do
        get :show, :id => @user2.id, :authentication_token => @user1.authentication_token, :format => :json
        response.code.should eq("200")
        body = JSON.parse(response.body)
        body.should have_key "latitude"
        body.should have_key "longitude"
      end

      it "should show one invited friend" do
        get :show, :id => @user4.id, :authentication_token => @user1.authentication_token, :format => :json
        response.code.should eq("200")
        body = JSON.parse(response.body)
        body["latitude"].should be_nil
        body["longitude"].should be_nil
      end

      it "should show one inviting friend" do
        get :show, :id => @user1.id, :authentication_token => @user4.authentication_token, :format => :json
        response.code.should eq("200")
        body = JSON.parse(response.body)
        body["latitude"].should be_nil
        body["longitude"].should be_nil
      end

      it "should return error if user is not friend at all" do
        UserFriendship.reject @user4, @user1
        get :show, :id => @user4.id, :authentication_token => @user1.authentication_token, :format => :json
        response.code.should eq("401")
      end

      describe "" do
        it "should reject friendship request" do
          delete :destroy, :id => @user1.id, :authentication_token => @user4.authentication_token, :format => :json
          @user4.reload
          @user1.reload
          @user4.inviting_friends.should_not include(@user1)
          @user1.invited_friends.should_not include(@user4)
          response.code.should eq("200")
        end

        it "should delete friendship request" do
          delete :destroy, :id => @user4.id, :authentication_token => @user1.authentication_token, :format => :json
          @user4.reload
          @user1.reload
          @user4.inviting_friends.should_not include(@user1)
          @user1.invited_friends.should_not include(@user4)
          response.code.should eq("200")
        end

        it "should delete friendship from inviting friend" do
          delete :destroy, :id => @user2.id, :authentication_token => @user1.authentication_token, :format => :json
          @user1.friends.should_not include(@user2)
          @user2.friends.should_not include(@user1)
          response.code.should eq("200")
        end
        it "should delete friendship from invited friend" do
          delete :destroy, :id => @user1.id, :authentication_token => @user2.authentication_token, :format => :json
          @user1.friends.should_not include(@user2)
          @user2.friends.should_not include(@user1)
          response.code.should eq("200")
        end
      end
    end
  end
end
