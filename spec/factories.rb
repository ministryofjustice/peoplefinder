FactoryGirl.define do
  sequence(:email) { |n| 'example.user.%d@digital.justice.gov.uk' % n }
  sequence(:given_name) { |n| "First name #{('a'.ord + (n % 25)).chr}" }
  sequence(:surname) { |n| "Surname #{('a'.ord + (n % 25)).chr}" }
  sequence(:building) { |n| '%d High Street' % n }
  sequence(:location_in_building) { |n| "Room #{n}, #{n.ordinalize}" }
  sequence(:city) { |n| 'Megacity %d' % n }
  sequence(:primary_phone_number) { |n| '07708 %06d' % (900_000 + n) }
  sequence(:pager_number) { |n| '07600 %06d' % (900_000 + n) }
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

    trait :with_details do
      primary_phone_number
      pager_number
      building
      location_in_building
      city
    end

    factory :person_with_multiple_logins do
      login_count 10
      last_login_at { 1.day.ago }
    end

    factory :super_admin do
      super_admin true
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

  factory :readonly_user do
  end
end
