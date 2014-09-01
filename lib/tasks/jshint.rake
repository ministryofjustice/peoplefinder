if %w[development test].include? Rails.env
  task(:default).prerequisites << task('jshint:lint')
end
