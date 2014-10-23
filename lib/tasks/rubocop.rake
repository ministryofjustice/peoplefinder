if Gem.loaded_specs.key?('rubocop')
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  task(:default).prerequisites << task(:rubocop)
end
