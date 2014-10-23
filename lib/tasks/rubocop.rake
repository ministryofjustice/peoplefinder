if defined?(RuboCop)
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  task(:default).prerequisites << task(:rubocop)
end
