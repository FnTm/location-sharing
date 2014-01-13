require 'spec_helper'

describe User do
  it { should have_many(:user_friendships) }
  it { should have_many(:friends) }
  it { should_not allow_value("blah").for(:email) }
  it { should_not allow_value("1").for(:password) }
  it { should allow_value("1jhdsJaZJd5").for(:password) }
end
