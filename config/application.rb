require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module ParliamentaryQuestions
  class Application < Rails::Application
    # Application Title (Populates <title>)
    config.app_title = 'Parliamentary Questions'
    # Proposition Title (Populates proposition header)
    config.proposition_title = 'Parliamentary Questions'
    # Current Phase (Sets the current phase and the colour of phase tags)
    # Presumed values: alpha, beta, live
    config.phase = 'alpha'
# Product Type (Adds class to body based on service type)
# Presumed values: information, service
    config.product_type = 'service'
# Feedback URL (URL for feedback link in phase banner)
    config.feedback_url = '#'
# Google Analytics ID (Tracking ID for the service)
    config.ga_id = ''

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/scrapers)

    config.encoding = "utf-8"

    config.active_record.schema_format = :sql

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    #config.assets.paths << "#{Rails}/vendor/assets/fonts"
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    config.generators do |g| 
      g.template_engine :erb
    end
  end
end
