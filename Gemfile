source 'https://rubygems.org'
ruby '2.1.2'
gem 'rails', '~> 4.1.5'

gem 'activejob_backport'
gem 'govspeak'
gem 'govuk_frontend_toolkit'
gem 'govuk_template'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'mail'
gem 'moj_internal_template',
  git: 'https://github.com/ministryofjustice/moj_internal_template.git',
  branch: 'master'
gem 'pg'
gem 'rack-timeout'
gem 'recipient_interceptor', '~> 0.1.2'
gem 'sass-rails', '~> 4.0.3'
gem 'scrypt'
gem 'uglifier', '>= 1.3.0'
gem 'unicorn', '~> 4.8.3'

group :development do
  gem 'spring'
end

group :test do
  gem 'capybara'
  gem 'email_spec'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'minitest'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'rspec-mocks'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'shoulda-matchers'
  gem 'simplecov', '~> 0.7.1', require: false
  gem 'simplecov-rcov', require: false
  gem 'timecop'
end

group :development, :test do
  gem 'factory_girl'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'jshint',
    git: 'https://github.com/threedaymonk/jshint.git',
    branch: 'master'
  gem 'konacha'
  gem 'pry'
  gem 'pry-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'brakeman', require: false
end

group :production do
  gem 'rails_12factor'
end
