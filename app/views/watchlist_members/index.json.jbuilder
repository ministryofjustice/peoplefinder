json.array!(@watchlist_members) do |watchlist_member|
  json.extract! watchlist_member, :id, :name, :email, :deleted
  json.url watchlist_member_url(watchlist_member, format: :json)
end
