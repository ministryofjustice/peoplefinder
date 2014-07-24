FactoryGirl.define do
  sequence :email do |n|
    domain = Rails.configuration.valid_login_domains.first
    "example.user.%d@%s" % [n, domain]
  end

  sequence :password do |n|
    "Insecure%03d" % n
  end

  factory :user do
    email {generate(:email)}

    password
    password_confirmation { password }
  end

  factory :agreement do
    association :manager, factory: :user
    association :jobholder, factory: :user
    budgetary_responsibilities [{}]
    after(:create) do |agreement|
      FactoryGirl.create(:objective, agreement: agreement)
    end
  end


  factory :objective do
    association :agreement, factory: :agreement
    objective_type { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    deliverables { Faker::Lorem.paragraph}
    measurements { Faker::Lorem.paragraph }
  end
end
