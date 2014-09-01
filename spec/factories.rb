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

  factory :user, aliases: [:author, :subject] do
    email { generate(:email) }
  end

  factory :token do
  end

  factory :review do
    subject
    author
    author_name { generate(:name) }
    review_period
  end

  factory :reply do
    subject
    author
    author_name { generate(:name) }
    review_period
  end

  factory :invitation do
    subject
    author
    author_name { generate(:name) }
    status 'no_response'
    review_period
  end

  factory :submission do
    subject
    author
    author_name { generate(:name) }
    status 'started'
    review_period
  end

  factory :review_period do
    initialize_with { ReviewPeriod.current || ReviewPeriod.create }
  end
end
