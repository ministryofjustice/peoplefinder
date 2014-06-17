json.array!(@progresses) do |progress|
  json.extract! progress, :id, :name, :progress_order
  json.url progress_url(progress, format: :json)
end
