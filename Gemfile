source 'https://rubygems.org'
ruby '2.1.1'
gem 'rails', '~> 4.1.1'

gem 'carrierwave',
  git: 'https://github.com/carrierwaveuploader/carrierwave.git',
  tag: 'cc39842e44edcb6187b2d379a606ec48a6b5e4a8'
gem 'coffee-rails', '~> 4.0.0'
gem 'elasticsearch-model', '~> 0.1.4'
gem 'elasticsearch-rails', '~> 0.1.4'
gem 'fog', '~> 1.20.0'
gem 'friendly_id', '~> 5.0.0'
gem 'govuk_template'
gem 'govuk_frontend_toolkit'
gem 'govspeak'
gem 'haml-rails'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'mail'
gem 'mini_magick'

if ENV['USE_LOCAL_TEMPLATE']
  gem 'moj_internal_template',
    path: '../moj_internal_template'
else
  gem 'moj_internal_template',
    git: 'https://github.com/ministryofjustice/moj_internal_template.git'
end
gem 'omniauth-gplus',
  git: 'https://github.com/ministryofjustice/omniauth-gplus.git'
gem 'paper_trail', '~> 3.0.2'
gem 'paranoia', '~> 2.0'
gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'simple_form', '~> 3.1.0.rc1'
gem 'uglifier', '>= 1.3.0'
gem 'will_paginate', '~> 3.0'

group :development do
  gem 'spring'
  gem 'thin'
end

group :development, :test do
  gem 'pry'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'rspec-mocks'
  gem 'guard-rspec', require: false
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'minitest'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'shoulda-matchers'
  gem 'simplecov', '~> 0.7.1', require: false
  gem 'simplecov-rcov', require: false
end

group :production do
  gem 'rails_12factor'
end
