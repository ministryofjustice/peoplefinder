require_relative "boot"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Peoplefinder
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified
    # here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record
    # auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
    # Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from
    # config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales',
    # '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    ActionView::Base.default_form_builder = GovukElementsFormBuilder::FormBuilder

    # Use AES-256-GCM authenticated encryption for encrypted cookies.
    # Also, embed cookie expiry in signed or encrypted cookies for increased security.
    #
    # This option is not backwards compatible with earlier Rails versions.
    # It's best enabled when your entire app is migrated and stable on 5.2.
    #
    # Existing cookies will be converted on read then written with the new scheme.
    config.action_dispatch.use_authenticated_cookie_encryption = true

    # Use AES-256-GCM authenticated encryption as default cipher for encrypting messages
    # instead of AES-256-CBC, when use_authenticated_message_encryption is set to true.
    config.active_support.use_authenticated_message_encryption = true

    # Add default protection from forgery to ActionController::Base instead of in
    # ApplicationController.
    config.action_controller.default_protect_from_forgery = true

    # Use SHA-1 instead of MD5 to generate non-sensitive digests, such as the ETag header.
    config.active_support.hash_digest_class = ::Digest::SHA1

    # Make `form_with` generate id attributes for any generated HTML tags.
    config.action_view.form_with_generates_ids = true

    # app title appears in the header bar
    config.app_title = "People Finder"

    config.admin_ip_ranges = ENV.fetch("ADMIN_IP_RANGES", "127.0.0.1")

    config.readonly_ip_whitelist = ENV.fetch("READONLY_IP_WHITELIST", "127.0.0.1")

    config.assets.paths << Rails.root.join("vendor/assets/components")

    config.support_email = ENV.fetch("SUPPORT_EMAIL")

    config.govuk_notify_api_key = ENV.fetch("GOVUK_NOTIFY_API_KEY", "")

    config.action_mailer.default_options = {
      from: config.support_email,
    }

    config.active_job.queue_adapter = :delayed_job

    config.active_record.schema_format = :ruby

    config.open_search_url = ENV["MOJ_PF_ES_URL"]

    config.rack_timeout = (ENV["RACK_TIMEOUT"] || 14)

    config.max_tokens_per_hour = ENV["MAX_TOKENS_PER_HOUR"]

    config.action_mailer.default_url_options = {
      host: ENV["ACTION_MAILER_DEFAULT_URL"],
      protocol: "https",
    }

    config.action_mailer.asset_host = "#{config.action_mailer.default_url_options[:protocol]}://#{config.action_mailer.default_url_options[:host] || 'localhost'}"

    # NOTE: ENV is set to 'dev','staging','production' on dev,staging, production respectively
    config.send_reminder_emails = (ENV["ENV"] == "production")

    # The following values are required by the phase banner
    config.phase = "live"
    config.feedback_url = "https://docs.google.com/a/digital.justice.gov.uk/forms/d/1dJ9xQ66QFvk8K7raf60W4ZXfK4yTQ1U3EeO4OLLlq88/viewform"

    config.autoload_paths << Rails.root.join("lib")

    require Rails.root.join("lib/csv_publisher/user_behavior_report.rb")

    # Adds classes that can be used with YAML.safe_load for the versions table used by paper_trail
    # See https://github.com/paper-trail-gem/paper_trail/blob/master/doc/pt_13_yaml_safe_load.md
    config.active_record.yaml_column_permitted_classes = [
      ::ActiveRecord::Type::Time::Value,
      ::ActiveSupport::TimeWithZone,
      ::ActiveSupport::TimeZone,
      ::BigDecimal,
      ::Date,
      ::Symbol,
      ::Time,
    ]
  end
end
