# require File.expand_path('../boot', __FILE__)
require_relative 'boot'
require 'rails/all'

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

    # app title appears in the header bar
    config.app_title = 'People Finder'

    config.admin_ip_ranges = ENV.fetch('ADMIN_IP_RANGES', '127.0.0.1')

    config.readonly_ip_whitelist = ENV.fetch('READONLY_IP_WHITELIST', '127.0.0.1')

    config.assets.paths << Rails.root.join('vendor/assets/components')

    config.support_email = ENV.fetch('SUPPORT_EMAIL')

    config.action_mailer.default_options = {
      from:  config.support_email
    }

    config.active_job.queue_adapter = :delayed_job

    config.active_record.schema_format = :ruby

    config.elastic_search_url = ENV['MOJ_PF_ES_URL']

    config.ga_tracking_id = (ENV['GA_TRACKING_ID'] || '')

    config.rack_timeout = (ENV['RACK_TIMEOUT'] || 14)

    config.max_tokens_per_hour = ENV['MAX_TOKENS_PER_HOUR']

    config.action_mailer.default_url_options = {
      host: ENV['ACTION_MAILER_DEFAULT_URL'],
      protocol: 'https'
    }

    config.action_mailer.asset_host = config.action_mailer.default_url_options[:protocol] +
                                      '://' +
                                      (config.action_mailer.default_url_options[:host] || 'localhost')

    # Note: ENV is set to 'dev','staging','production' on dev,staging, production respectively
    config.send_reminder_emails = (ENV['ENV'] == 'production')

    # The following values are required by the phase banner
    config.phase = 'live'
    config.feedback_url = 'https://docs.google.com/a/digital.justice.gov.uk/forms/d/1dJ9xQ66QFvk8K7raf60W4ZXfK4yTQ1U3EeO4OLLlq88/viewform'

    # make the geckoboard publisher available generally
    # NOTE: may need to eager load paths instead if lib code is commonly called
    config.autoload_paths << Rails.root.join('lib')

    require Rails.root.join('lib', 'csv_publisher', 'user_behavior_report.rb')

    config.active_record.sqlite3.represent_boolean_as_integer = true
  end

end
