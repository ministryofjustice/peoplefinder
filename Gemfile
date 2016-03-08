source 'https://rubygems.org'
ruby '2.2.4'
gem 'rails', '~> 4.2.4'

gem 'ancestry'
gem 'delayed_job', git: 'https://github.com/collectiveidea/delayed_job.git',
    ref: '5f914105c1c38ca73a486d63de8ad62f254b3d72' # needed for queue_attributes configuration
gem 'delayed_job_active_record'
gem 'elasticsearch-model', '~> 0.1.4'
gem 'elasticsearch-rails', '~> 0.1.4'
gem 'faker'
gem 'fog'
gem 'friendly_id', '~> 5.0.0'
gem 'govspeak'
gem 'govuk_frontend_toolkit'
gem 'govuk_template'
gem 'haml-rails'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails', '>= 4.0.4'
gem 'keen'
gem 'mail'
gem 'mini_magick'
gem 'moj_internal_template', '~> 0.1.7'
gem 'netaddr'
gem 'paper_trail', '~> 4.0.0.beta'
gem 'pg'
gem 'premailer-rails'
gem 'pundit'
gem 'recipient_interceptor', '~> 0.1.2'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'unf'
gem 'unicorn', '~> 4.8.3'
gem 'useragent', '~> 0.10.0'
gem 'virtus'
gem 'whenever'
gem 'will_paginate', '~> 3.0'

gem 'carrierwave',
  git: 'https://github.com/carrierwaveuploader/carrierwave.git',
  tag: 'cc39842e44edcb6187b2d379a606ec48a6b5e4a8'
gem 'carrierwave-bombshelter'
gem 'omniauth-gplus',
  git: 'https://github.com/ministryofjustice/omniauth-gplus.git'

group :assets do
  gem 'coffee-rails'
end

group :production do
  gem 'sentry-raven', git: 'https://github.com/getsentry/raven-ruby.git'
  gem 'logstasher', '~> 0.6.2'
end

group :development do
  gem 'foreman'
  gem 'mailcatcher'
  gem 'guard-rspec', require: false
end

group :development, :test do
  gem 'brakeman'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'minitest'
  gem 'poltergeist'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'timecop'
  gem 'jasmine-rails'
  gem 'guard-jasmine'
  gem 'guard-rubocop', require: false
  gem 'rubocop-rspec'
end

group :development, :test, :assets do
  gem 'dotenv-rails'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'fuubar'
  gem 'database_cleaner'
  gem 'site_prism'
end
