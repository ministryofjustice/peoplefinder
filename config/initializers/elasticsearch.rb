if Rails.env.production?
  Elasticsearch::Model.client =
    Elasticsearch::Client.new(Rails.configuration.elastic_search_url)
end
