FactoryGirl.define do
  factory :group do
    sequence :name do |n|
      "Group-%04d" % n
    end
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
