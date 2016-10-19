Rails.application.configure do
  #
  # Used primarily to set Google+ API client ID and secret to
  # allow log in authentication for local development.
  config.before_configuration do
    Dotenv.load Rails.root.join('.env.local')
  end

  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.assets.raise_runtime_errors = true
  config.action_mailer.default_url_options = {
    host: 'localhost',
    port: 3000,
    protocol: 'http'
  }
  config.action_mailer.asset_host = ENV['ACTION_MAILER_DEFAULT_URL'] || 'http://localhost:3000'
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }
end
