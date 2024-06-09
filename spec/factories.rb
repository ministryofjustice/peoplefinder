FactoryBot.define do
  sequence(:email) { |n| sprintf("example.user.%d@digital.justice.gov.uk", n) }
  sequence(:given_name) { |n| "First name #{('a'.ord + (n % 25)).chr}" }
  sequence(:surname) { |n| "Surname #{('a'.ord + (n % 25)).chr}" }
  sequence(:building) { |n| sprintf("%d High Street", n) }
  sequence(:location_in_building) { |n| "Room #{n}, #{n.ordinalize}" }
  sequence(:city) { |n| sprintf("Megacity %d", n) }
  sequence(:primary_phone_number) { |n| sprintf("07708 %06d", (900_000 + n)) }
  sequence(:pager_number) { |n| sprintf("07600 %06d", (900_000 + n)) }
  sequence(:phone_number) { |n| sprintf("07700 %06d", (900_000 + n)) }

  factory :permitted_domain do
    domain { "digital.justice.gov.uk" }
  end

  factory :department, class: "Group" do
    initialize_with do
      Group.where(ancestry_depth: 0).first_or_create(name: "Ministry of Justice")
    end
  end

  factory :group do
    sequence :name do |n|
      sprintf("Group-%04d", n)
    end
    association :parent, factory: :department
  end

  factory :membership do
    person
    group

    factory :membership_default do
      role { nil }
      leader { false }
      subscribed { true }
      group_id { create(:department).id }
    end
  end

  factory :person do
    given_name
    surname
    email

    # validation requires team membership existence
    after :build do |peep, _evaluator|
      department = create(:department)
      peep.memberships << build(:membership, group: department, person: nil) if peep.memberships.empty?
    end

    trait :with_details do
      primary_phone_number
      pager_number
      building
      location_in_building
      city
    end

    trait :with_random_dets do
      after :build do
        PermittedDomain.create!(domain: "example.com") unless PermittedDomain.exists?(domain: "example.com")
      end

      given_name { Faker::Name.unique.first_name }
      surname { Faker::Name.unique.last_name }
      email { "#{given_name}.#{surname}@example.com" }
      primary_phone_number { Faker::PhoneNumber.phone_number }
      login_count { Random.rand(1..20) }
      last_login_at { login_count == 0 ? nil : Random.rand(15).days.ago }
    end

    trait :for_demo_csv do
      after :build do |peep, _evaluator|
        PermittedDomain.create!(domain: "example.com") unless PermittedDomain.exists?(domain: "example.com")
        peep.memberships.first.role = Faker::Job.title
      end

      given_name { Faker::Name.first_name }
      surname { Faker::Name.last_name }
      sequence(:email) { |n| sprintf("%{given_name}.%{surname}.%{unique}.@digital.justice.gov.uk", given_name:, surname:, unique: n) }
      primary_phone_number { Faker::PhoneNumber.phone_number }
      secondary_phone_number { Faker::PhoneNumber.phone_number }
      login_count { Random.rand(1..20) }
      last_login_at { login_count == 0 ? nil : Random.rand(15).days.ago }
      description { Faker::Lorem.sentences.join(" ") }
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
        team { nil }
        leader { false }
        subscribed { true }
        role { nil }
        sole_membership { false }
      end
      after(:build) do |peep, evaluator|
        if peep.memberships.map(&:group).include? evaluator.team
          memberships = peep.memberships.select { |m| m.group == evaluator.team }
          memberships.each do |membership|
            membership.assign_attributes(leader: evaluator.leader, subscribed: evaluator.subscribed, role: evaluator.role)
          end
        else
          peep.memberships << build(:membership, group: evaluator.team, person: peep, leader: evaluator.leader, subscribed: evaluator.subscribed, role: evaluator.role)
        end
        peep.memberships = peep.memberships.select { |m| m.group_id == evaluator.team.id } if evaluator.sole_membership
      end
    end

    # i.e. unassigned person - person in group with ancestry of 0 (i.e. MoJ)
    trait :department_member do
      after(:create) do |p|
        department = create(:department)
        create(:membership, person: p, group: department)
      end
    end

    factory :person_with_multiple_logins do
      login_count { 10 }
      last_login_at { 1.day.ago }
    end

    factory :super_admin do
      super_admin { true }
    end
  end

  factory :information_request do
    message { "This is the information request message body" }
  end

  factory :token do
    user_email { generate(:email) }
  end

  factory :profile_photo do
    image do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/profile_photo_valid.png").to_s,
      )
    end

    trait :invalid_extension do
      image do
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec/fixtures/placeholder.bmp").to_s,
        )
      end
    end

    trait :non_image do
      image do
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec/fixtures/invalid_rows.csv").to_s,
        )
      end
    end

    trait :too_small_dimensions do
      image do
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec/fixtures/profile_photo_too_small_dimensions.png").to_s,
        )
      end
    end

    trait :large_dimensions do
      image do
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec/fixtures/profile_photo_large.png").to_s,
        )
      end
    end
  end

  factory :readonly_user do
  end

  factory :report do
    content { "id,full_name,login_count\n1,John Smith,5\n" }
    name { "factory_test_report" }
    extension { "csv" }
    mime_type { "text/csv" }
  end

  factory :queued_notification do
    session_id { "MyString" }
    person_id { 1 }
    current_user_id { 1 }
    changes_json { "{}" }
    edit_finalised { false }
    sent { false }
  end

  factory :external_user, class: "ExternalUser" do
    sequence(:email) { |n| sprintf("example.user.%d@gov.sscl.uk", n) }
  end
end
