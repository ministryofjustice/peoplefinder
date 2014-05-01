require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module ParliamentaryQuestions
  class Application < Rails::Application
    # app title appears in the header bar
    config.app_title = 'Parliamentary Questions'
    # phase governs text indicators and highlight colours
    # presumed values: alpha, beta, live
    config.phase = 'alpha'
    # product type may also govern highlight colours
    # known values: information, service
    config.product_type = 'service'
    # govbranding switches on or off the crown logo, full footer and NTA font
    config.govbranding = true

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/scrapers)

    config.encoding = "utf-8"

    config.feedback_email = "noemail@noemail.com"

    config.active_record.schema_format = :sql

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.assets.enabled = false
    config.assets.precompile += %w(
      gov-static/gov-goodbrowsers.css
      gov-static/gov-ie6.css
      gov-static/gov-ie7.css
      gov-static/gov-ie8.css
      gov-static/gov-fonts.css
      gov-static/gov-fonts-ie8.css
      gov-static/gov-print.css
      moj-base.css
      gov-static/gov-ie.js
      application-admin.js
    )
  end
end
