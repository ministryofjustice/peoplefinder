# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "timecop"
require "paper_trail/frameworks/rspec"
require "shoulda-matchers"
require "capybara/rspec"
require "site_prism"
require "awesome_print"

if ENV["SKIP_SIMPLECOV"].to_s.downcase == "false"
  require "simplecov"
  SimpleCov.start "rails" do
    add_filter "/gem/"
    add_filter ".bundle"
  end
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  unless ENV["CHROME_DEBUG"]
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--start-maximized")
    options.add_argument("--window-size=1980,2080")
    options.add_argument("--enable-features=NetworkService,NetworkServiceInProcess")
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.javascript_driver = :headless_chrome

Capybara.default_max_wait_time = 3
Capybara.server = :puma, { Silent: true }

# Fix load order issue on Circle CI 2.0
require File.expand_path("support/pages/base.rb", __dir__)

Dir[File.expand_path("../{lib,app/*}", __dir__)].each do |path|
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }

Dir[File.expand_path("controllers/concerns/shared_examples*.rb", __dir__)].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
  config.include FactoryBot::Syntax::Methods
  config.include SpecSupport::Login
  config.include SpecSupport::Search
  config.include SpecSupport::Carrierwave
  config.include SpecSupport::OrgBrowser
  config.include SpecSupport::Email
  config.include SpecSupport::Profile
  config.include SpecSupport::DbHelper
  config.include SpecSupport::OpenSearchHelper
  config.include SpecSupport::FeatureFlags
  config.include SpecSupport::AppConfig
end
