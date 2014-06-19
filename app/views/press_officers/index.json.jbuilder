json.array!(@press_officers) do |press_officer|
  json.extract! press_officer, :id, :name, :email
  json.url press_officer_url(press_officer, format: :json)
end
