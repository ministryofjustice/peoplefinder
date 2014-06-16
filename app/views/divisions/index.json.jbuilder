json.array!(@divisions) do |division|
  json.extract! division, :id, :name, :directorate_id
  json.url division_url(division, format: :json)
end
