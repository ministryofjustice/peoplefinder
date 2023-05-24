source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'rails', '~> 6.1'
gem 'text'
gem 'ancestry'
gem 'awesome_print'
gem 'aws-sdk-s3'
gem 'delayed_job_active_record', '~> 4.1.7'
gem 'daemons'
gem 'elasticsearch', '~> 7.13.0'
gem 'elasticsearch-model', '~> 7.2.1'
gem 'elasticsearch-rails', '~> 7.2.1'
gem 'faker', '~> 2.20'
gem 'fastimage', '~> 2.1'
gem 'ffi', '>= 1.9.24'
gem 'fog-aws'
gem 'friendly_id'
gem 'govspeak'
gem 'govuk_template', '~> 0.26.0'
gem 'govuk_frontend_toolkit', '9.0.1'
gem 'govuk_elements_rails', '2.2.1'
gem 'govuk_elements_form_builder', '0.1.1'
gem 'govuk_notify_rails'
gem 'geckoboard-ruby', '~> 0.4.0'
gem 'haml-rails'
gem 'jbuilder', '~> 2.11'
gem 'jquery-rails'
gem 'keen'
gem 'mail'
gem 'mini_magick', '>= 4.9.4'
gem 'net-smtp', require: false
gem 'netaddr', '~> 2.0.4'
gem 'paper_trail'
gem 'pg'
gem 'premailer-rails', '~> 1.9'
gem 'prometheus_exporter'
gem 'pundit', '~>2.3'
gem 'puma'
gem 'rack-protection'
gem 'recipient_interceptor', '~> 0.3.1'
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
gem 'carrierwave'

group :assets do
  gem 'coffee-rails'
end

group :production do
  gem 'logstasher', '~> 2.1.5'
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
  gem 'simplecov', '~> 0.22', require: false
  gem 'site_prism'
  gem 'webmock'
  gem 'webdrivers'
  gem 'rspec-json_expectations'
end

group :development, :test do
  gem 'debug'
  gem 'brakeman', require: false
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'guard-jasmine'
  gem 'jasmine-rails'
  gem 'rubocop', '1.51'
  gem 'rubocop-rspec', '~> 1.41.0', require: false
  gem 'rubocop-ast', require: false
  gem 'rubocop-performance', '~> 1.7.1', require: false
  gem 'rubocop-rails', require: false
  gem 'annotate'
end

group :development, :test, :assets do
  gem 'dotenv-rails'
end
