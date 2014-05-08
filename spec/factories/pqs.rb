# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :PQ do
    PIN 1
    HouseID 1
    RaisingMemberID 1
    DateRaised "2014-05-08 13:45:31"
    ResponseDue "2014-05-08 13:45:31"
    Question "MyString"
    Answer nil
  end
end
