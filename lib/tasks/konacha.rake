if %w[development test].include? Rails.env
  namespace :konacha do
    task :explain do
      puts "Running JavaScript specs..."
    end
    task(:run).prerequisites << task(:explain)
  end
  task(:default).prerequisites << task('konacha:run')
end
