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

  sequence :rating do |n|
    n % 6
  end

  sequence :verbiage do |n|
    "Long bit of text N° %d" % n
  end

  factory :user, aliases: [:subject] do
    email { generate(:email) }
    participant true
  end

  factory :author, class: User do
    email { generate(:email) }
  end

  factory :token do
  end

  factory :review do
    subject
    author
    author_name { generate(:name) }
    relationship :peer

    factory :complete_review do
      rating_1 { generate(:rating) }
      rating_2 { generate(:rating) }
      rating_3 { generate(:rating) }
      rating_4 { generate(:rating) }
      rating_5 { generate(:rating) }
      rating_6 { generate(:rating) }
      rating_7 { generate(:rating) }
      rating_8 { generate(:rating) }
      rating_9 { generate(:rating) }
      rating_10 { generate(:rating) }
      rating_11 { generate(:rating) }
      leadership_comments { generate(:verbiage) }
      how_we_work_comments { generate(:verbiage) }
    end
  end

  factory :reply do
    subject
    author
    author_name { generate(:name) }
    relationship :peer
  end

  factory :invitation do
    subject
    author
    author_name { generate(:name) }
    relationship :peer
    status :no_response
  end

  factory :submission do
    subject
    author
    author_name { generate(:name) }
    relationship :peer
    status :started
  end
end
