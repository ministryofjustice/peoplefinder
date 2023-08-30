source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").strip

gem "ancestry"
gem "awesome_print"
gem "aws-sdk-s3"
gem "carrierwave"
gem "daemons"
gem "delayed_job_active_record", "~> 4.1.7"
gem "faker", "~> 3.2"
gem "fastimage", "~> 2.1"
gem "ffi", ">= 1.9.24"
gem "fog-aws"
gem "friendly_id"
gem "geckoboard-ruby", "~> 0.4.0"
gem "govspeak"
gem "govuk_elements_form_builder", "0.1.1"
gem "govuk_elements_rails", "2.2.1"
gem "govuk_frontend_toolkit", "9.0.1"
gem "govuk_notify_rails"
gem "govuk_template", "~> 0.26.0"
gem "haml-rails"
gem "jbuilder", "~> 2.11"
gem "jquery-rails"
gem "keen"
gem "mail", ">= 2.8"
gem "mini_magick", ">= 4.9.4"
gem "netaddr", "~> 2.0.4"
gem "opensearch-model", github: "compliance-innovations/opensearch-rails"
gem "opensearch-rails", github: "compliance-innovations/opensearch-rails"
gem "paper_trail"
gem "pg"
gem "premailer-rails", "~> 1.9"
gem "prometheus_exporter"
gem "puma"
gem "pundit", "~>2.3"
gem "rack-protection"
gem "rails", "~> 6.1"
gem "recipient_interceptor", "~> 0.3.1"
gem "sanitize"
gem "sass-rails"
gem "sentry-rails"
gem "sentry-ruby"
gem "sprockets", "~> 3.7.2"
gem "text"
gem "tzinfo-data"
gem "uglifier", ">= 2.7.2"
gem "unf"
gem "useragent", "~> 0.10"
gem "virtus"
gem "will_paginate", "~> 3.0", ">=3.0.3"
gem "will_paginate-bootstrap", "~> 1.0", ">= 1.0.1"

group :assets do
  gem "coffee-rails"
end

group :production do
  gem "logstasher", "~> 2.1.5"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "daemon"
  gem "meta_request"
  gem "rb-fsevent", require: RUBY_PLATFORM[/darwin/i].to_s.size.positive?
  gem "spring-commands-rspec"
end

group :test do
  gem "database_cleaner", "~> 1.8.5"
  gem "rails-controller-testing"
  gem "rspec-json_expectations"
  gem "simplecov", "~> 0.22", require: false
  gem "site_prism"
  gem "webmock"
end

group :development, :test do
  gem "annotate"
  gem "brakeman"
  gem "capybara"
  gem "debug"
  gem "factory_bot_rails"
  gem "launchy"
  gem "listen"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "timecop"
end

group :development, :test, :assets do
  gem "dotenv-rails"
end
