if %w[development test].include? Rails.env
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.verbose = false
  end

  task(:default).prerequisites << task(:spec)
end
