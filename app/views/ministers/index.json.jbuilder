json.array!(@ministers) do |minister|
  json.extract! minister, :id, :name, :title, :email, :deleted
  json.url minister_url(minister, format: :json)
end
