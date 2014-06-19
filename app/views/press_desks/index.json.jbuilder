json.array!(@press_desks) do |press_desk|
  json.extract! press_desk, :id, :name
  json.url press_desk_url(press_desk, format: :json)
end
