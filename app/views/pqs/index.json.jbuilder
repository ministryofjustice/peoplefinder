json.array!(@pqs) do |pq|
  json.extract! pq, :id
  json.url pq_url(pq, format: :json)
end
