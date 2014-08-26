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

  factory :review do
    subject

    sequence :author_name do |n|
      "Author-%04d" % n
    end

    sequence :author_email do
      generate(:email)
    end
  end

  factory :subject, class: User do
    sequence :email do
      generate(:email)
    end
  end
end
