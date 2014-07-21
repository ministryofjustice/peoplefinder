FactoryGirl.define do
  sequence :email do |n|
    domain = Rails.configuration.valid_login_domains.first
    "example.user.%d@%s" % [n, domain]
  end

  factory :user do
    email
    password '12345678'
    password_confirmation '12345678'
  end

  factory :agreement do
    association :manager, factory: :user
    association :jobholder, factory: :user
    budgetary_responsibilities [{}]
    objectives [{}]
  end
end
