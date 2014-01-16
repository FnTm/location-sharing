require 'spec_helper'

describe API::V1::RegistrationsController do
  describe "Sign up" do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
      @credentials = {:email => 'asd@def.com', :password => 'password', :password_confirmation => 'password'}
    end

    it "should create the user" do
      post :create, :user => @credentials, :format => :json
      response.code.should eq("200")
    end

    it "should return error message if the passwords are not matching" do
      @credentials[:password] = "wrong password"
      post :create, :user => @credentials, :format => :json
      response.code.should eq("401")
      response.body['password_confirmation'].should_not be_nil
    end
  end

  describe "Change Password" do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
      @credentials = {:email => 'asd@def.com', :password => 'password', :password_confirmation => 'password', :authentication_token => 'asd'}
      @user = FactoryGirl.create(:user, @credentials)
    end

    it "should change the password" do
      put :update, :id => @user.id, 'user' => {'email' => 'asd@def.com', 'password' => 'new_password', 'password_confirmation' => 'new_password', :current_password => 'password'}, :authentication_token => @user.authentication_token, :email => @user.email, :format => :json
      response.code.should eq("200")
    end

    it "should return error message if the passwords are not matching" do
      @credentials[:password] = "wrong password"
      put :update, :id => @user.id, 'user' => @credentials, :authentication_token => @user.authentication_token, :format => :json
      response.code.should eq("401")
      response.body['password_confirmation'].should_not be_nil
    end

    it "should return error message if the token is not passed" do
      put :update, :id => @user.id, 'user' => @credentials, :format => :json
      response.code.should eq("401")
      response.body['errors'].should_not be_nil
    end

    it "should return error message if the current password is wrong" do
      @credentials[:current_password] = "wrong password"
      put :update, :id => @user.id, 'user' => @credentials, :authentication_token => @user.authentication_token, :format => :json
      response.code.should eq("401")
      response.body['errors'].should_not be_nil
    end
  end

  describe "Show user data" do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
      @credentials = {:email => 'asd@def.com', :name => "Juris Jurjāns", :password => 'password', :password_confirmation => 'password', :authentication_token => 'asd', :latitude => "1337.0", :longitude => "555.0"}
      @user = FactoryGirl.create(:user, @credentials)
    end

    it "should return user data" do
      get :show, :id => @user.id, :authentication_token => @user.authentication_token, :format => :json
      response.code.should eq("200")
      body = JSON.parse(response.body)
      body["id"].should eq(@user.id)
      body["name"].should eq(@user.name)
      body["email"].should eq(@user.email)
      body["latitude"].should eq(@user.latitude)
      body["longitude"].should eq(@user.longitude)
    end

    it "should not return password" do
      get :show, :id => @user.id, :authentication_token => @user.authentication_token, :format => :json
      response.code.should eq("200")
      body = JSON.parse(response.body)
      body["password"].should be_nil
      body["encrypted_password"].should be_nil
    end
  end

  describe "Delete account" do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
      @credentials = {:email => 'asd@def.com', :password => 'password', :password_confirmation => 'password', :authentication_token => 'asd'}
      @user = FactoryGirl.create(:user, @credentials)
    end

    it "should delete user" do
      delete :destroy, :id => @user.id, :authentication_token => @user.authentication_token, :format => :json
      response.code.should eq("200")
    end

    it "should not delete user when authentication token is not present" do
      delete :destroy, :id => @user.id, :email => @user.email, :format => :json
      response.code.should eq("401")
      response.body['errors'].should_not be_nil
    end
  end

  describe "Update location" do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
      @credentials = {:email => 'asd@def.com', :password => 'password', :password_confirmation => 'password', :authentication_token => 'asd'}
      @user = FactoryGirl.create(:user, @credentials)
      @user.latitude = 0
      @user.longitude = 0

      @lat = 155
      @long = 250
    end

    it "should update location" do
      put :update_location, :id => @user.id, 'user' => {:latitude => @lat, :longitude => @long}, :authentication_token => @user.authentication_token, :format => :json
      response.code.should eq("200")
      @user = User.find_by_id(@user.id)
      @user.latitude.should eq(@lat)
      @user.longitude.should eq(@long)
    end

    it "should not update location if no token was passed" do
      put :update_location, :id => @user.id, 'user' => {:latitude => @lat, :longitude => @long}, :format => :json
      response.code.should eq("401")
    end
    it "should not update anything except location" do
      put :update_location, :id => @user.id, 'user' => {:latitude => @lat, :longitude => @long, :password => "password2", :password_confirmation => "password2", :email => "def@asd.com"}, :authentication_token => @user.authentication_token, :format => :json
      response.code.should eq("200")
      @user = User.find_by_id(@user.id)
      @user.latitude.should eq(@lat)
      @user.longitude.should eq(@long)
      @user.email.should eq(@credentials[:email])
    end
  end
end
