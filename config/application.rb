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

    def self.env_integer(key, default)
      ENV.fetch(key, default).to_i
    end

    config.app_title = 'SCS 360° Appraisals'

    config.phase = 'alpha'
    config.feedback_url =
      'mailto:scs-appraisals-feedback@digital.justice.gov.uk'

    config.noreply_email = ENV.fetch('EMAIL_NOREPLY_ADDRESS')

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV.fetch('SMTP_ADDRESS'),
      port: ENV.fetch('SMTP_PORT'),
      domain: ENV.fetch('SMTP_DOMAIN'),
      user_name: ENV.fetch('SMTP_USERNAME'),
      password: ENV.fetch('SMTP_PASSWORD'),
      authentication: 'plain',
      enable_starttls_auto: true
    }

    config.generators do |g|
      g.test_framework :rspec, fixture: true, views: false
      g.integration_tool :rspec, fixture: true, views: true
      g.fixture_replacement :factory_girl, dir: "spec/support/factories"
    end

    config.action_mailer.default_url_options = { host: ENV.fetch('HOST') }

    config.rack_timeout = env_integer('RACK_TIMEOUT', 14)

    config.token_timeout = env_integer('TOKEN_TIMEOUT_IN_MONTHS', 6).months
  end
end
