# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :watchlist_member do
    name "Watchlist Member 1"
    email "member.one@watchlist.com"
    deleted false
  end
end
