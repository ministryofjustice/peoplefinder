if %w[development test].include? Rails.env
  require 'jshint'
  require 'jshint/reporters'

  namespace :jshint do
    desc "Runs JSHint on this project's JavaScript assets"
    task :lint_with_fail_on_error => :environment do
      puts "Running JSHint..."
      linter = Jshint::Lint.new
      linter.lint
      puts Jshint::Reporters::Default.new(linter.errors).report
      fail if linter.errors.any? { |_, errors| errors.any? }
    end
  end

  task(:default).prerequisites << task('jshint:lint_with_fail_on_error')
end
