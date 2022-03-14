source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 6.1.4.7'
gem 'nokogiri', '~> 1.13'
gem 'text'
gem 'ancestry'
gem 'awesome_print'
gem 'aws-sdk', '~> 2.7.3'
gem 'delayed_job_active_record', '~> 4.1.0'
gem 'daemons'
gem 'elasticsearch', '~> 7.13.0'
gem 'elasticsearch-model', '~> 7.0.0'
gem 'elasticsearch-rails', '~> 7.0.0'
gem 'faker', '~> 1.7'
gem 'fastimage', '~> 2.1'
gem 'ffi', '>= 1.9.24'
gem 'fog-aws'
gem 'friendly_id'
gem 'govspeak'
gem 'govuk_template', '~> 0.26.0'
gem 'govuk_frontend_toolkit', '9.0.1'
gem 'govuk_elements_rails', '2.2.1'
gem 'govuk_elements_form_builder', '0.1.1'
gem 'geckoboard-ruby', '~> 0.4.0'
gem 'haml-rails'
gem 'jbuilder', '~> 2.10'
gem 'jquery-rails'
gem 'keen'
gem 'mail'
gem 'mini_magick', '>= 4.9.4'
gem 'netaddr', '~> 2.0.4'
gem 'paper_trail'
gem 'pg'
gem 'premailer-rails', '~> 1.9'
gem 'prometheus_exporter'
gem 'pundit', '~>2.1'
gem 'puma'
gem 'recipient_interceptor', '~> 0.1.2'
gem 'sanitize'
gem 'sass-rails'
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'sprockets', '~> 3.7.2'
gem 'uglifier', '>= 2.7.2'
gem 'unf'
gem 'useragent', '~> 0.10'
gem 'virtus'
gem 'will_paginate', '~> 3.0', '>=3.0.3'
gem 'will_paginate-bootstrap', '~> 1.0', '>= 1.0.1'
gem 'tzinfo-data'
gem 'carrierwave',
    git: 'https://github.com/carrierwaveuploader/carrierwave.git',
    tag: 'cc39842e44edcb6187b2d379a606ec48a6b5e4a8'

github 'sinatra/sinatra' do
  gem 'rack-protection'
end

group :assets do
  gem 'coffee-rails'
end

group :production do
  gem 'logstasher', '~> 0.6.2'
end

group :development do
  gem 'spring-commands-rspec'
  gem 'rb-fsevent', require: RUBY_PLATFORM[/darwin/i].to_s.size > 0
  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'daemon'
end

group :test do
  gem 'rails-controller-testing'
  gem 'database_cleaner', '~> 1.8.5'
  gem 'site_prism'
  gem 'webmock'
  gem 'webdrivers'
  gem 'rspec-json_expectations'
end

group :development, :test do
  gem 'byebug'
  gem 'brakeman', require: false
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'minitest'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', '~> 0.17.1'
  gem 'timecop'
  gem 'guard-jasmine'
  gem 'jasmine-rails'
  gem 'rubocop', '~> 0.86.0'
  gem 'rubocop-rspec', '~> 1.39.0', require: false
  gem 'rubocop-ast', '~> 0.0.3', require: false
  gem 'rubocop-performance', '~> 1.6.0', require: false
  gem 'rubocop-rails', require: false
  gem 'annotate'
end

group :development, :test, :assets do
  gem 'dotenv-rails'
end
