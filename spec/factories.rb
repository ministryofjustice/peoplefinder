FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "example.user.%d@digital.justice.gov.uk" % n
    end
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
