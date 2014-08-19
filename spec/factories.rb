FactoryGirl.define do
  factory :department, class: 'Group' do
    initialize_with do
      Group.where(ancestry_depth: 0).first_or_create(name: 'Ministry of Justice')
    end
  end

  factory :group do
    sequence :name do |n|
      "Group-%04d" % n
    end
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
end
