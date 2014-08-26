FactoryGirl.define do
  sequence :email do |n|
    "example.user.%d@example.com" % n
  end

  sequence :password do |n|
    "Insecure%03d" % n
  end

  factory :user do
    email { generate(:email) }
  end

  factory :token do
  end
end
