# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :action_officer do
    name "action officer 1"
    email "action.officer@email.com"
    deputy_director_id 1
  end
end
