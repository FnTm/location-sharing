require "spec_helper"

describe API::V1::SessionsController do
  describe "Session" do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
      @credentials = {:email => 'asd@def.com', :password => 'password', :password_confirmation => 'password', :authentication_token => 'asd'}
      @user = FactoryGirl.create(:user, @credentials)
    end

    describe "Sign in" do
      it "should sign in successfully and return authentication token" do
        @user.confirm!
        post :create, 'user' => {:email => 'asd@def.com', :password => 'password'}, :format => :json
        response.code.should eq("200")
        controller.current_user.should_not be_nil
        controller.should be_signed_in
        JSON.parse(response.body)['authentication_token'].should eq(@credentials[:authentication_token])
      end

      it "should return authentication failure message" do
        @user.confirm!
        post :create, 'user' => {:email => 'asd@sad.com', :password => 'asd'}, :format => :json
        response.code.should eq("401")
        controller.current_user.should be_nil
        controller.should_not be_signed_in
      end
    end

    describe "Sign Out" do
      it "should sign out the user successfully" do
        @user.confirm!
        sign_in @user
        delete :destroy, :authentication_token => @user.authentication_token, :format => :json
        controller.current_user.should be_nil
        controller.should_not be_signed_in
        response.code.should eq("200")
      end

      it "should return error message if the token is not passed" do
        @user.confirm!
        sign_in @user
        delete :destroy, :format => :json
        response.code.should eq("401")
        response.body['errors'].should_not be_nil
      end

      it "should return error if logging in unconfirmed user" do
        post :create, 'user' => {:email => 'asd@def.com', :password => 'password'}, :format => :json
        response.code.should eq("403")
        response.body.should include("api.v1.user.unconfirmed_user")
      end
    end
  end
end
