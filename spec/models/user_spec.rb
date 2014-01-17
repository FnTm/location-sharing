require 'spec_helper'

describe User do
  it { should have_many(:user_friendships) }
  it { should have_many(:friends) }
  it { should_not allow_value("blah").for(:email) }
  it { should_not allow_value("").for(:email) }
  it { should_not allow_value(nil).for(:email) }
  it { should_not allow_value("1").for(:password) }
  it { should allow_value("1jhdsJaZJd5").for(:password) }
  it "should not allow to create 2 users with the same e-mail" do
    credentials = {:email => 'asd@def.com', :password => 'password', :password_confirmation => 'password', :name => 'My name'}
    user = User.new credentials
    user.save.should eq(true)
    user = User.new credentials
    user.save.should eq(false)
  end
end
