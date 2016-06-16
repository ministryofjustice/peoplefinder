if %w(development test).include? Rails.env
  require 'coffee_script'
  task(:default).prerequisites.unshift('jasmine:ci') if Gem.loaded_specs.key?('jasmine')
end
