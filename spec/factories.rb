FactoryGirl.define do
  sequence :email do |n|
    domain = Rails.configuration.valid_login_domains.first
    "example.user.%d@%s" % [n, domain]
  end

  sequence :password do |n|
    "Insecure%03d" % n
  end

  factory :user do
    email

    password
    password_confirmation { password }
  end

  factory :agreement do
    association :manager, factory: :user
    association :jobholder, factory: :user
    budgetary_responsibilities [{}]
    objectives [{}]
  end
end
