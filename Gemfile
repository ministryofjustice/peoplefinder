source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "ancestry"
gem "awesome_print"
gem "aws-sdk-s3"
gem "carrierwave"
gem "daemons"
gem "delayed_job_active_record", ">= 4.1.10"
gem "faker", "~> 3.2"
gem "fastimage", "~> 2.2"
gem "ffi", ">= 1.9.24"
gem "fog-aws"
gem "friendly_id"
gem "govspeak"
gem "govuk_app_config"
gem "govuk_elements_form_builder", "0.1.1"
gem "govuk_elements_rails", "2.2.1"
gem "govuk_frontend_toolkit", "9.0.1"
gem "govuk_notify_rails"
gem "govuk_template", "~> 0.26.0"
gem "haml-rails"
gem "jbuilder", "~> 2.11"
gem "jquery-rails"
gem "mail", ">= 2.8"
gem "mini_magick", ">= 4.9.4"
gem "netaddr", "~> 2.0.6"
gem "opensearch-model", github: "compliance-innovations/opensearch-rails"
gem "opensearch-rails", github: "compliance-innovations/opensearch-rails"
gem "paper_trail"
gem "pg"
gem "puma"
gem "pundit", "~> 2.3"
gem "rails", ">= 7.2"
gem "sanitize"
gem "sass-rails"
gem "sentry-rails"
gem "sentry-ruby"
gem "sprockets-rails"
gem "terser"
gem "text"
gem "tzinfo-data"
gem "useragent", "~> 0.10"
gem "virtus"
gem "will_paginate", "~> 4.0"
gem "will_paginate-bootstrap", "~> 1.0", ">= 1.0.1"

group :production do
  gem "logstasher", "~> 2.1.5"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :test do
  gem "database_cleaner"
  gem "database_cleaner-active_record", ">= 2.2.0"
  gem "rails-controller-testing"
  gem "rspec-json_expectations"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  gem "site_prism"
  gem "timecop"
  gem "webmock"
end

group :development, :test do
  gem "annotate"
  gem "brakeman"
  gem "capybara"
  gem "debug"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "listen"
  gem "parallel_tests"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "shoulda-matchers"
end
