json.array!(@deputy_directors) do |deputy_director|
  json.extract! deputy_director, :id, :name, :email, :division_id
  json.url deputy_director_url(deputy_director, format: :json)
end
