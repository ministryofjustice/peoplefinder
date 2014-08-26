source 'https://rubygems.org'
ruby '2.1.1'
gem 'rails', '~> 4.1.5'

gem 'govuk_template'
gem 'govuk_frontend_toolkit'
gem 'haml-rails'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'mail'
gem 'moj_internal_template',
  git: 'https://github.com/ministryofjustice/moj_internal_template.git'
gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'simple_form', '~> 3.1.0.rc1'
gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'spring'
  gem 'thin'
end

group :test do
  gem 'email_spec'
  gem 'capybara-email'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'minitest'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'rspec-mocks'
  gem 'shoulda-matchers'
  gem 'simplecov', '~> 0.7.1', require: false
  gem 'simplecov-rcov', require: false
end

group :development, :test do
  gem 'factory_girl'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'pry'
  gem 'pry-rails'
  gem 'dotenv-rails'
  gem 'rubocop', require: false
end

group :production do
  gem 'rails_12factor'
end
