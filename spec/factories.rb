FactoryGirl.define do
  sequence(:email) { |n| 'example.user.%d@digital.justice.gov.uk' % n }
  sequence(:given_name) { |n| 'First name-%04d' % n }
  sequence(:surname) { |n| 'Surname-%04d' % n }
  sequence(:building) { |n| '%d High Street' % n }
  sequence(:city) { |n| 'Megacity %d' % n }
  sequence(:phone_number) { |n| '07700 %06d' % (900_000 + n) }

  factory :department, class: 'Peoplefinder::Group' do
    initialize_with do
      Peoplefinder::Group.where(ancestry_depth: 0).first_or_create(name: 'Ministry of Justice')
    end
  end

  factory :group, class: 'Peoplefinder::Group' do
    sequence :name do |n|
      'Group-%04d' % n
    end
    association :parent, factory: :department
  end

  factory :person, class: 'Peoplefinder::Person' do
    given_name
    surname
    email

    factory :person_with_multiple_logins do
      login_count 10
      last_login_at { 1.day.ago }
    end

    factory :super_admin do
      super_admin true
    end
  end

  factory :community, class: 'Peoplefinder::Community' do
    sequence :name do |n|
      'Community-%04d' % n
    end
  end

  factory :information_request, class: 'Peoplefinder::InformationRequest' do
    message "This is the information request message body"
  end

  factory :membership, class: 'Peoplefinder::Membership' do
    person
    group
  end

  factory :token, class: 'Peoplefinder::Token' do
    user_email { generate(:email) }
  end
end
