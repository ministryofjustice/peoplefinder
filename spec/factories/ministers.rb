# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :minister do
    name "firstname"
    title "MP"
    email "first.name@mp.com"
    deleted false
  end
end
