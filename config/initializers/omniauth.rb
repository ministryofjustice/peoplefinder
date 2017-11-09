require 'ditsso_internal'

Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV['DEVELOPER_AUTH_STRATEGY']
    provider :developer, fields: [:first_name, :last_name, :email],
                         uid_field: :email,
                         name: 'ditsso_internal'
  else
    provider 'ditsso_internal',
      ENV['DITSSO_INTERNAL_CLIENT_ID'],
      ENV['DITSSO_INTERNAL_CLIENT_SECRET']
  end
end
