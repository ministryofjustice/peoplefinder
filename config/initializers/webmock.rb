if Rails.env.test?
  require 'webmock'
  allowed_connect = [
    'chromedriver.storage.googleapis.com',
    Rails.application.config.elastic_search_url,
  ]
  WebMock.disable_net_connect!(allow: allowed_connect)
  WebMock.allow_net_connect!(net_http_connect_on_start: true)
end
