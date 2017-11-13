source 'https://rubygems.org'
ruby '2.3.4'
gem 'rails', '~> 4.2.8'
gem 'text'
gem 'active_model_serializers', '~> 0.10.2'
gem 'activerecord-session_store'
gem 'ancestry', '~> 2.1'
gem 'awesome_print'
gem 'aws-sdk', '~> 2.5', '>= 2.5.5'
gem 'country_select'
gem 'delayed_job', git: 'https://github.com/collectiveidea/delayed_job.git',
    ref: '5f914105c1c38ca73a486d63de8ad62f254b3d72' # needed for queue_attributes configuration
gem 'delayed_job_active_record', '~> 4.1.0'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'faker', '~> 1.7'
gem 'fastimage', '~> 2.1'
gem 'fog'
gem 'friendly_id', '~> 5.2.1'
gem 'govspeak'
gem 'govuk_template',         '~> 0.19.2'
gem 'govuk_frontend_toolkit', '>= 5.2.0'
gem 'govuk_elements_rails',   '>= 1.1.2'
gem 'govuk_elements_form_builder', '>= 0.0.3', '~> 0.0'
gem 'geckoboard-ruby', '~> 0.4.0'
gem 'haml-rails'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails', '>= 4.0.4'
gem 'json'
gem 'keen'
gem 'mail', '~> 2.6.6.rc1'
gem 'mini_magick'
gem 'netaddr'
gem 'omniauth-oauth2'
gem 'paper_trail', '~> 4.0.2'
gem 'pg'
gem 'premailer-rails', '~> 1.9'
gem 'pundit', '~> 1.1'
gem 'recipient_interceptor', '~> 0.1.2'
gem 'sass-rails', '~> 5.0.6'
gem 'uglifier', '>= 2.7.2'
gem 'unf'
gem 'unicorn', '~> 4.8.3'
gem 'unicorn-worker-killer', '~> 0.4.4'
gem 'useragent', '~> 0.10'
gem 'virtus'
gem 'whenever', require: false
gem 'will_paginate', '~> 3.0', '>=3.0.3'
gem 'will_paginate-bootstrap', '~> 1.0', '>= 1.0.1'
gem 'zendesk_api'

gem 'carrierwave',
  git: 'https://github.com/carrierwaveuploader/carrierwave.git',
  tag: 'cc39842e44edcb6187b2d379a606ec48a6b5e4a8'

group :assets do
  gem 'coffee-rails'
end

group :production do
  gem 'sentry-raven', git: 'https://github.com/getsentry/raven-ruby.git'
  gem 'logstasher', '~> 0.6.2'
  gem 'rails_12factor'
end

group :development do
  gem 'foreman'
  gem 'spring-commands-rspec'
  gem 'rb-fsevent', require: RUBY_PLATFORM[/darwin/i].to_s.size > 0
  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'daemon'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'site_prism'
  gem 'webmock'
  gem 'whenever-test'
  gem 'rspec-json_expectations'
end

group :development, :test do
  gem 'byebug'
  gem 'brakeman', require: false
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'minitest'
  gem 'poltergeist'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.5', '>= 3.5.1'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'timecop'
  gem 'guard-jasmine'
  gem 'jasmine-rails'
  gem 'rubocop'
  gem 'rubocop-rspec', '~> 1.15.0'
  gem 'annotate'
end

group :development, :test, :assets do
  gem 'dotenv-rails'
end
