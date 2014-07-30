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
    association :staff_member, factory: :user
  end


  factory :objective do
    association :agreement, factory: :agreement
    objective_type { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    deliverables { Faker::Lorem.paragraph}
    measurements { Faker::Lorem.paragraph }
  end

  factory :budgetary_responsibility do
    association :agreement, factory: :agreement
    budget_type "Capital"
    sequence(:value) { |n| 10 * n + 1 }
    description { Faker::Lorem.paragraph }
  end
end
