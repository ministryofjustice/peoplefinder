require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "peoplefinder"

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.active_record.schema_format = :sql
    config.active_record.raise_in_transactional_callbacks = true

    config.valid_login_domains = [/(.*)\.gov.uk/]

    config.support_email = 'support@example.com'

    config.action_mailer.default_url_options = {
      host: 'www.example.com'
    }

    config.action_mailer.asset_host = 'www.example.com'

    config.action_mailer.default_options = {
      from:  config.support_email
    }

    config.ga_tracking_id = ''

    config.app_title = 'People Finder Dummy'

    config.elastic_search_url = ''

    # The following values are required by the phase banner
    config.phase = 'beta'
    config.feedback_url = 'https://docs.google.com/a/digital.justice.gov.uk/forms/d/1dJ9xQ66QFvk8K7raf60W4ZXfK4yTQ1U3EeO4OLLlq88/viewform'

    # Time in hours for auth token to live
    config.token_ttl = 3
  end
end
