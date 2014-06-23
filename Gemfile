source 'https://rubygems.org'
ruby '2.1.1'
gem 'rails', '4.1.1'

gem 'coffee-rails', '~> 4.0.0'
gem 'friendly_id', '~> 5.0.0'
gem 'govuk_frontend_toolkit'
gem 'haml-rails'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'moj_frontend_toolkit_gem',
  git: 'https://github.com/ministryofjustice/moj_frontend_toolkit_gem.git',
  ref: '8826821' # TODO: change to tag when branch remove_gem_lock is merged
gem 'omniauth-gplus', '~> 2.0'
gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'simple_form', '~> 3.1.0.rc1'
gem 'uglifier', '>= 1.3.0'
gem 'paper_trail', '~> 3.0.2'
gem 'paranoia', '~> 2.0'
gem 'will_paginate', '~> 3.0'
gem 'carrierwave', '~> 0.10.0'
gem 'fog', '~> 1.20.0'

group :development do
  gem 'spring'
  gem 'thin'
end

group :development, :test do
  gem 'pry'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'rspec-mocks'
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'minitest'
  gem 'shoulda-matchers'
end

group :production do
  gem 'rails_12factor'
end
