if Rails.env.production?
  Elasticsearch::Model.client =
    Elasticsearch::Client.new(url: Rails.configuration.elastic_search_url)
end

# Use config.elastic_search_url in local environment
if ENV.fetch('PF_HOST_NAME', false) == 'peoplefinder.docker'
  Elasticsearch::Model.client =
    Elasticsearch::Client.new(url: Rails.configuration.elastic_search_url)
end
