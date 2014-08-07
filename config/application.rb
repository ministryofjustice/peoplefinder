require File.expand_path('../boot', __FILE__)

require 'rails/all'

require 'elasticsearch/rails/instrumentation'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Peoplefinder
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

    # app title appears in the header bar
    config.app_title = 'People Finder'

    config.valid_login_domains = %w[
      digital.justice.gov.uk
      digital.cabinet-office.gov.uk
    ]
    config.start_secure_session = (ENV['SSL_ON'] =~ /(true|yes|1)$/) == 0

    config.assets.paths << Rails.root.join('vendor', 'assets', 'components')
  end
end
