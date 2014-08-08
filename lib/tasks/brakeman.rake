require 'brakeman'

namespace :brakeman do
  desc "Run Brakeman"
  task :run, :output_files do |t, args|

    files = args[:output_files].split(' ') if args[:output_files]
    Brakeman.run :app_path => ".", :output_files => files, :print_report => true
  end

end

desc 'Run Brakeman when running the whole test suite'
task :default do
  Brakeman.run :app_path => ".", :print_report => true
end