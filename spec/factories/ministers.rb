# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :minister do
    name "MyString"
    title "MyString"
    email "MyString"
    deleted false
  end
end
