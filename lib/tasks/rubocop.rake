if Gem.loaded_specs.has_key?('rubocop')
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  task(:default).prerequisites << task(:rubocop)
end
