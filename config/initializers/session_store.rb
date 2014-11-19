# Be sure to restart your server when you modify this file.

secure_cookie = ENV.fetch('SECURE_COOKIES', 'true')
secure_cookie = %w[1 true].include?(secure_cookie)

Rails.application.config.session_store :cookie_store,
  key: '_scs_appraisals_session',
  secure: secure_cookie
