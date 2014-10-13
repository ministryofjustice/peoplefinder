if Rails.env.production?
  Elasticsearch::Model.client =
    Elasticsearch::Client.new(url: Rails.configuration.elastic_search_url)
end
