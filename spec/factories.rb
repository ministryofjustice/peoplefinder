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

    factory :admin_user do
      administrator true
    end
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

    factory :no_response_review do
      status :no_response
    end

    factory :declined_review do
      status :declined
      reason_declined 'Just because'
    end

    factory :accepted_review do
      status :accepted
    end

    factory :started_review do
      status :started
    end

    factory :submitted_review do
      status :submitted
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

  factory :invitation do
    subject
    author
    author_name { generate(:name) }
    relationship :peer
    status :no_response
  end

  factory :identity do
    sequence :username do |n|
      "username-%d" % n
    end

    password { generate(:password) }
    password_confirmation { password }

    user
  end
end
