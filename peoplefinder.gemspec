$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "peoplefinder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "peoplefinder"
  s.version     = Peoplefinder::VERSION
  s.authors     = ["Toby Privett", "David Heath", "Paul Battley", "James Darling"]
  s.email       = ["people-finder@digital.justice.gov.uk"]
  s.homepage    = "http://github.com/ministryofjustice/peoplefinder"
  s.summary     = "Searchable people database for your organisation"
  s.description = "The peoplefinder provides searchable staff profiles for your organisation. Since it's a rails engine, you can re-skin it for your organisation."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "LICENCE.txt", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'rails', '~> 4.1.5'
  s.add_dependency 'ancestry'
  s.add_dependency 'carrierwave', '~> 0.10.0'
  s.add_dependency 'elasticsearch-model', '~> 0.1.4'
  s.add_dependency 'elasticsearch-rails', '~> 0.1.4'
  s.add_dependency 'fog', '~> 1.20.0'
  s.add_dependency 'friendly_id', '~> 5.0.0'
  s.add_dependency 'govspeak'
  s.add_dependency 'govuk_frontend_toolkit'
  s.add_dependency 'govuk_template'
  s.add_dependency 'haml-rails'
  s.add_dependency 'jbuilder', '~> 2.0'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'mail'
  s.add_dependency 'mini_magick'
  s.add_dependency 'moj_internal_template', '~> 0.1.2'
  s.add_dependency 'omniauth-gplus', '~> 2.0.1'
  s.add_dependency 'paper_trail', '~> 3.0.5'
  s.add_dependency 'pg'
  s.add_dependency 'recipient_interceptor', '~> 0.1.2'
  s.add_dependency 'sass-rails', '~> 4.0.3'
  s.add_dependency 'select2-rails'
  s.add_dependency 'simple_form', '~> 3.1.0.rc1'
  s.add_dependency 'uglifier', '>= 1.3.0'
  s.add_dependency 'unicorn', '~> 4.8.3'
  s.add_dependency 'will_paginate', '~> 3.0'
  s.add_dependency 'unf'

  s.add_development_dependency 'brakeman'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'dotenv-rails'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-mocks'
  s.add_development_dependency 'rspec-rails', '~> 3.0.0'
  s.add_development_dependency 'rubocop', '~> 0.26.1'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'teaspoon'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'simplecov', '~> 0.7.1'
  s.add_development_dependency 'simplecov-rcov'
end
