if %w( production staging ).include? ENV['ENV']

  set :output, standard: '/var/log/cron.log', error: '/var/log/cron_error.log'

  job_type :rails_script, "cd /usr/src/app && ./rails_runner.sh ':task' :output"

  every :weekday, at: '6:00am' do
    rails_script 'GeckoboardPublisher::PhotoProfilesReport.new.publish!'
  end

  every :weekday, at: '6:10am' do
    rails_script 'GeckoboardPublisher::ProfilesPercentageReport.new.publish!'
  end

  every :weekday, at: '6:20am' do
    rails_script 'GeckoboardPublisher::TotalProfilesReport.new.publish!'
  end

  every :weekday, at: '6:30am' do
    rails_script 'GeckoboardPublisher::ProfilesChangedReport.new.publish!'
  end

  every :weekday, at: '6:40am' do
    rails_script 'GeckoboardPublisher::ProfileCompletionsReport.new.publish!'
  end

  every :weekday, at: '8am' do
    rails_script 'NeverLoggedInNotifier.send_reminders'
  end

  every :weekday, at: '8:10am' do
    rails_script 'TeamDescriptionNotifier.send_reminders'
  end

  every :weekday, at: '8:15am' do
    rails_script 'PersonUpdateNotifier.send_reminders'
  end

end
