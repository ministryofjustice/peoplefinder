FactoryGirl.define do
  factory :group do
    sequence :name do |n|
      "Group-%04d" % n
    end
  end
end
