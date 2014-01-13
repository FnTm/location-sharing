FactoryGirl.define do
  factory :user do
    name 'Test User'
    email 'example@example.com'
    password 'mypassword'
    password_confirmation 'mypassword'
  end
end
