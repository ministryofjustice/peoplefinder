if Rails.env.production?
  OpenSearch::Model.client =
    OpenSearch::Client.new(url: Rails.configuration.open_search_url)
end
