require File.expand_path('../boot', __FILE__)

require 'rails/all'
require File.expand_path('../../config/initializers/host_env.rb', __FILE__)

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

    # app title appears in the header bar
    config.app_title = 'People Finder'

    config.admin_ip_ranges = ENV.fetch('ADMIN_IP_RANGES', '127.0.0.1')

    config.assets.paths << Rails.root.join('vendor', 'assets', 'components')

    config.support_email = ENV.fetch('SUPPORT_EMAIL')

    config.readonly = {
      header: ENV['READONLY_HEADER'],
      value: ENV['READONLY_VALUE']
    }

    config.action_mailer.default_options = {
      from:  config.support_email
    }

    config.active_job.queue_adapter = :delayed_job
    config.active_job.queue_name_prefix = Rails.host.env

    config.active_record.raise_in_transactional_callbacks = true
    config.active_record.schema_format = :sql

    config.elastic_search_url = ENV['MOJ_PF_ES_URL']

    config.ga_tracking_id = (ENV['GA_TRACKING_ID'] || '')

    config.rack_timeout = (ENV['RACK_TIMEOUT'] || 14)

    config.max_tokens_per_hour = ENV['MAX_TOKENS_PER_HOUR']

    config.action_mailer.default_url_options = {
      host: ENV['ACTION_MAILER_DEFAULT_URL']
    }

    config.action_mailer.asset_host = ENV['ACTION_MAILER_DEFAULT_URL']

    # Note: ENV is set to 'dev','staging','production' on dev,staging, production respectively
    config.send_reminder_emails = Rails.host.production?

    # The following values are required by the phase banner
    config.phase = 'live'
    config.feedback_url = 'https://docs.google.com/a/digital.justice.gov.uk/forms/d/1dJ9xQ66QFvk8K7raf60W4ZXfK4yTQ1U3EeO4OLLlq88/viewform'
  end
end
