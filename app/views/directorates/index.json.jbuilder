json.array!(@directorates) do |directorate|
  json.extract! directorate, :id, :name
  json.url directorate_url(directorate, format: :json)
end
