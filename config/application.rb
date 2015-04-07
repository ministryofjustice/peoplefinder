require File.expand_path('../boot', __FILE__)

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

    # app title appears in the header bar
    config.app_title = 'People Finder'

    config.assets.paths << Rails.root.join('vendor', 'assets', 'components')

    config.support_email =
        ENV['SUPPORT_EMAIL'] || 'people-finder@digital.justice.gov.uk'

    config.action_mailer.default_options = {
      from:  config.support_email
    }

    config.active_job.queue_adapter = :delayed_job

    config.active_record.raise_in_transactional_callbacks = true
    config.active_record.schema_format = :sql

    config.elastic_search_url = ENV['MOJ_PF_ES_URL']

    config.disable_communities = true

    config.ga_tracking_id = (ENV['GA_TRACKING_ID'] || '')

    config.rack_timeout = (ENV['RACK_TIMEOUT'] || 14)

    config.action_mailer.default_url_options = {
      host: ENV['ACTION_MAILER_DEFAULT_URL'],
      protocol: (ENV['SSL_ON'] != 'false' ? 'https' : 'http')
    }

    config.action_mailer.asset_host = ENV['ACTION_MAILER_DEFAULT_URL']

    # The following values are required by the phase banner
    config.phase = 'beta'
    config.feedback_url = 'https://docs.google.com/a/digital.justice.gov.uk/forms/d/1dJ9xQ66QFvk8K7raf60W4ZXfK4yTQ1U3EeO4OLLlq88/viewform'
  end
end
