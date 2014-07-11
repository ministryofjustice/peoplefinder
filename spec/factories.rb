FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "example.user.%d@digital.justice.gov.uk" % n
    end
  end

  factory :agreement do
    association :manager, factory: :user
    association :jobholder, factory: :user
  end
end
