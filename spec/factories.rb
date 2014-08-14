FactoryGirl.define do
  factory :department, class: 'Group' do
    sequence :name do |n|
      "Department-%04d" % n
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
