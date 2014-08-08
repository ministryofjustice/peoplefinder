Rails.application.config.middleware.use OmniAuth::Builder do
  provider :gplus, ENV['GPLUS_CLIENT_ID'], ENV['GPLUS_CLIENT_SECRET'],
    scope: 'openid,profile,email'
end
