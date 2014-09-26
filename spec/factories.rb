FactoryGirl.define do
  sequence :email do |n|
    "example.user.%d@digital.justice.gov.uk" % n
  end

  factory :department, class: 'Group' do
    initialize_with do
      Group.where(ancestry_depth: 0).first_or_create(name: 'Ministry of Justice')
    end
    team_email_address { generate(:email) }
  end

  factory :group do
    sequence :name do |n|
      "Group-%04d" % n
    end
    team_email_address { generate(:email) }
    association :parent, factory: :department
  end

  factory :person do
    sequence :surname do |n|
      "Surname-%04d" % n
    end
  end

  factory :membership do
    person
    group
  end

  factory :token do
    user_email { generate(:email) }
  end
end
