Rails.application.configure do
  config.force_ssl = true
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = true
  config.assets.compile = false
  config.assets.digest = true
  config.assets.version = '1.0.4'
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false
  config.action_mailer.smtp_settings = {
    address: 'smtp.sendgrid.net',
    port: '587',
    authentication: :plain,
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    domain: ENV['SENDGRID_DOMAIN'] || 'people-finder.dsd.io',
    enable_starttls_auto: true
  }
  config.filter_parameters += [
    :given_name, :surname, :email, :primary_phone_number,
    :secondary_phone_number, :location, :email
  ]
  if ENV['INTERCEPTED_EMAIL_RECIPIENT'].present?
    Mail.register_interceptor RecipientInterceptor.new(
      ENV['INTERCEPTED_EMAIL_RECIPIENT'],
      subject_prefix: '[STAGING]'
    )
  end
  config.logstasher.enabled = true
  config.logstasher.suppress_app_log = true
  config.logstasher.log_level = Logger::INFO
  config.logstasher.logger_path =
      "#{Rails.root}/log/logstash_#{Rails.env}.json"
  config.logstasher.source = 'logstasher'
end
