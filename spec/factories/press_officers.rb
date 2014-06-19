# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :press_officer do
    name "Press Officer One"
    email "po.one@press.office.com"
    press_desk_id "1"
  end
end
