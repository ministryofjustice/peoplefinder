require 'jshint'
require 'jshint/reporters'

namespace :jshint do
  desc "Runs JSHint, the JavaScript lint tool over this projects JavaScript assets"
  task :lint_with_fail_on_error => :environment do
    puts "Running JSHint"
    linter = Jshint::Lint.new
    linter.lint
    reporter = Jshint::Reporters::Default.new(linter.errors)
    reported = reporter.report.strip
    puts reported
    fail unless reported =~ /\A0 errors/
  end
end

if %w[development test].include? Rails.env
  task(:default).prerequisites << task('jshint:lint_with_fail_on_error')
end
