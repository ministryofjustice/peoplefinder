if %w[development test].include? Rails.env
  namespace :teaspoon do
    task :explain do
      puts 'Running JavaScript specs...'
    end
    task(:run).prerequisites << task(:explain)
  end
  task(:default).prerequisites << task(:teaspoon)
end
