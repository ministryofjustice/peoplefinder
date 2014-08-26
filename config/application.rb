require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SCSAppraisals
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified
    # here.  Application configuration should go into files in
    # config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record
    # auto-convert to this zone.  Run "rake -D time" for a list of tasks for
    # finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from
    # config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path +=
    #   Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    #
    config.app_title = 'SCS Appraisals'

    config.valid_login_domains = %w[
      digital.justice.gov.uk
      digital.cabinet-office.gov.uk
    ]

    config.noreply_email = ENV['EMAIL_NOREPLY_ADDRESS']

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV['SMTP_ADDRESS'],
      port: ENV['SMTP_PORT'],
      domain: ENV['SMTP_DOMAIN'],
      user_name: ENV['SMTP_USERNAME'],
      password: ENV['SMTP_PASSWORD'],
      authentication: 'plain',
      enable_starttls_auto: true
    }

    config.generators do |g|
      g.test_framework :rspec, fixture: true, views: false
      g.integration_tool :rspec, fixture: true, views: true
      g.fixture_replacement :factory_girl, dir: "spec/support/factories"
    end

    config.action_mailer.default_url_options = { host: ENV['HOST'] }

    config.rack_timeout = (ENV['RACK_TIMEOUT'] || 14)
  end
end
