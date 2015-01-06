require 'paper_trail'
require 'haml-rails'
require 'sass/rails'
require 'ancestry'
require 'elasticsearch/model'
require 'elasticsearch/rails'
require 'govuk_frontend_toolkit'
require 'govuk_template'
require 'moj_internal_template'
require 'jquery-rails'
require 'friendly_id'
require 'govspeak'
require 'carrierwave'
require 'omniauth-gplus'
require 'will_paginate'
require 'select2-rails'

if %w[rspec-core rspec-mocks].all? { |gemname| Gem.loaded_specs.key?(gemname) }
  require 'rspec/core'
  require 'rspec/mocks'
end

module Peoplefinder
  class Engine < ::Rails::Engine
    isolate_namespace Peoplefinder

    config.autoload_paths << File.expand_path('..', File.dirname(__FILE__))
    config.active_record.schema_format = :sql
  end
end
