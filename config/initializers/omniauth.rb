Rails.application.config.middleware.use OmniAuth::Builder do
  provider :gplus,
    ENV['GPLUS_CLIENT_ID'],
    ENV['GPLUS_CLIENT_SECRET'],
    scope: 'openid,profile,email'

  provider :azure_oauth2,
    {
      client_id: ENV['AZURE_CLIENT_ID'],
      client_secret: ENV['AZURE_CLIENT_SECRET'],
      tenant_id: ENV['AZURE_TENANT_ID']
    }

end
