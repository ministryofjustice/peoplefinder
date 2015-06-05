FactoryGirl.define do
  sequence(:email) { |n| 'example.user.%d@digital.justice.gov.uk' % n }
  sequence(:given_name) { |n| 'First name-%04d' % n }
  sequence(:surname) { |n| 'Surname-%04d' % n }
  sequence(:building) { |n| '%d High Street' % n }
  sequence(:city) { |n| 'Megacity %d' % n }
  sequence(:phone_number) { |n| '07700 %06d' % (900_000 + n) }

  factory :department, class: 'Group' do
    initialize_with do
      Group.where(ancestry_depth: 0).first_or_create(name: 'Ministry of Justice')
    end
  end

  factory :group do
    sequence :name do |n|
      'Group-%04d' % n
    end
    association :parent, factory: :department
  end

  factory :person do
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

  factory :community do
    sequence :name do |n|
      'Community-%04d' % n
    end
  end

  factory :information_request do
    message "This is the information request message body"
  end

  factory :membership do
    person
    group
  end

  factory :token do
    user_email { generate(:email) }
  end

  factory :profile_photo do
    image Rack::Test::UploadedFile.new(
      File.join(Rails.root, 'spec', 'fixtures', 'placeholder.png')
    )
  end
end
