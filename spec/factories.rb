FactoryGirl.define do
  sequence :email do |n|
    'example.user.%d@digital.justice.gov.uk' % n
  end

  factory :department, class: 'Peoplefinder::Group' do
    initialize_with do
      Peoplefinder::Group.where(ancestry_depth: 0).first_or_create(name: 'Ministry of Justice')
    end
    team_email_address { generate(:email) }
  end

  factory :group, class: 'Peoplefinder::Group' do
    sequence :name do |n|
      'Group-%04d' % n
    end
    team_email_address { generate(:email) }
    association :parent, factory: :department
  end

  factory :person, class: 'Peoplefinder::Person' do
    sequence :surname do |n|
      'Surname-%04d' % n
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
