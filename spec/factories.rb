FactoryGirl.define do
  sequence :email do |n|
    "example.user.%d@example.com" % n
  end

  sequence :password do |n|
    "Insecure%03d" % n
  end

  sequence :name do |n|
    "Name-%04d" % n
  end

  factory :user do
    email { generate(:email) }
  end

  factory :token do
  end

  factory :review do
    subject
    author_name { generate(:name) }
    author_email { generate(:email) }
  end

  factory :submission do
    subject
    author_name { generate(:name) }
    author_email { generate(:email) }
    status 'accepted'
  end

  factory :feedback_request do
    subject
    author_name { generate(:name) }
    author_email { generate(:email) }
  end

  factory :subject, class: User do
    email { generate(:email) }
  end
end
