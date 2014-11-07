require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'action_mailer/log_subscriber'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SCSAppraisals
  class Application < Rails::Application
    # Custom Logging
    config.log_level = :info
    config.logstasher.enabled = true
    config.logstasher.suppress_app_log = true
    config.logstasher.log_level = Logger::INFO
    config.logstasher.logger_path =
        "#{Rails.root}/log/logstash_#{Rails.env}.json"
    config.logstasher.source = 'logstasher'

    def self.env_integer(key, default)
      ENV.fetch(key, default).to_i
    end

    # For the MOJ internal template
    config.app_title = 'SCS 360° Appraisals'
    config.phase = 'alpha'

    config.generators do |g|
      g.test_framework :rspec, fixture: true, views: false
      g.integration_tool :rspec, fixture: true, views: true
      g.fixture_replacement :factory_girl, dir: "spec/support/factories"
    end

    config.rack_timeout = env_integer('RACK_TIMEOUT', 14)
    config.token_timeout = env_integer('TOKEN_TIMEOUT_IN_MONTHS', 6).months
    config.ga_id = ENV.fetch('GA_ID', '')
  end
end
