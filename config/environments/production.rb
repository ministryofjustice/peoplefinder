Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_assets = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  if ENV['ASSET_HOST']
    config.action_controller.asset_host = ENV['ASSET_HOST']
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.noreply_email = ENV.fetch('EMAIL_NOREPLY_ADDRESS')

  config.action_mailer.default_url_options = {
    host: ENV['SENDING_HOST'] || ENV['ACTION_MAILER_DEFAULT_URL']
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV['SMTP_HOSTNAME'] || 'smtp.sendgrid.net',
    port: ENV['SMTP_PORT'] || '587',
    authentication: :login,
    user_name: ENV['SMTP_USERNAME'] || ENV['SENDGRID_USERNAME'],
    password: ENV['SMTP_PASSWORD'] || ENV['SENDGRID_PASSWORD'],
    domain: ENV['SENDING_HOST'] || 'heroku.com',
    enable_starttls_auto: true
  }

  config.feedback_url = ENV.fetch('FEEDBACK_URL')
  config.survey_url = ENV.fetch('SURVEY_URL')

  if ENV['INTERCEPTED_EMAIL_RECIPIENT'].present?
    Mail.register_interceptor RecipientInterceptor.new(
      ENV['INTERCEPTED_EMAIL_RECIPIENT'],
      subject_prefix: '[STAGING]'
    )
  end
end
