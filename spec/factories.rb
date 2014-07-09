FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "example.user.%d@digital.justice.gov.uk" % n
    end
  end
end
