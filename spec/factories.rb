
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

  factory :permitted_domain do
    domain 'digital.justice.gov.uk'
  end

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

    trait :with_random_dets do
      after :build do
        PermittedDomain.create(domain: 'example.com') unless PermittedDomain.exists?(domain: 'example.com')
      end

      given_name { Faker::Name.unique.first_name }
      surname { Faker::Name.unique.last_name }
      email { "#{given_name}.#{surname}@example.com" }
      primary_phone_number { Faker::PhoneNumber.phone_number }
      login_count { Random.rand(20) + 1 }
      last_login_at { login_count == 0 ? nil : Random.rand(15).days.ago }
    end

    trait :with_photo do
      association :profile_photo, factory: :profile_photo
    end

    # i.e. person in a group with ancestry of 1+
    trait :team_member do
      after(:create) do |p|
        create(:membership, person: p)
      end
    end

    trait :member_of do
      transient do
        team nil
      end
      after(:create) do |peep, evaluator|
        create(:membership, person: peep, group: evaluator.team)
      end
    end

    # i.e. unassigned person - person in group with ancestry of 0 (i.e. MoJ)
    trait :department_member do
      after(:create) do |p|
        department = Group.where(ancestry_depth: 0).first_or_create(name: 'Ministry of Justice')
        create(:membership, person: p, group: department)
      end
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
      File.join(Rails.root, 'spec', 'fixtures', 'profile_photo_valid.png')
    )

    trait :invalid_extension do
      image Rack::Test::UploadedFile.new(
        File.join(Rails.root, 'spec', 'fixtures', 'placeholder.bmp')
      )
    end

    trait :non_image do
      image Rack::Test::UploadedFile.new(
        File.join(Rails.root, 'spec', 'fixtures', 'invalid_rows.csv')
      )
    end

    trait :too_small_dimensions do
      image Rack::Test::UploadedFile.new(
        File.join(Rails.root, 'spec', 'fixtures', 'profile_photo_too_small_dimensions.png')
      )
    end

    trait :large_dimensions do
      image Rack::Test::UploadedFile.new(
        File.join(Rails.root, 'spec', 'fixtures', 'profile_photo_large.png')
      )
    end
  end

  factory :readonly_user do
  end

  factory :report do
    content <<~CSV
      id,full_name,login_count
      1,John Smith,5
    CSV
    name 'factory_test_report'
    extension 'csv'
    mime_type 'text/csv'
  end

  factory :queued_notification do
    session_id "MyString"
    person_id 1
    current_user_id 1
    changes_json '{}'
    edit_finalised false
    sent false
  end
end
