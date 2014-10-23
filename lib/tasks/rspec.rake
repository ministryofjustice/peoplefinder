if defined?(RSpec::Core)
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.verbose = false
  end

  task(:default).prerequisites << task(:spec)
end
