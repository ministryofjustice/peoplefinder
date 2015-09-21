require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'pry-byebug'
require 'timecop'
require 'paper_trail/frameworks/rspec'
require 'shoulda-matchers'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'site_prism'

unless ENV['SKIP_SIMPLECOV']
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start 'rails' do
    add_filter '/gem/'
    add_filter '.bundle'
  end
  SimpleCov.minimum_coverage 95
end

Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 3

Dir[File.expand_path('../../{lib,app/*}', __FILE__)].each do |path|
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
  config.include FactoryGirl::Syntax::Methods
  config.include SpecSupport::Login
  config.include SpecSupport::Search
  config.include SpecSupport::Carrierwave
  config.include SpecSupport::OrgBrowser
  config.include SpecSupport::Email
  config.include SpecSupport::Profile
  config.include SpecSupport::FeatureFlags
  config.include SpecSupport::AppConfig
end
