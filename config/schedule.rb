if ENV['ENV'] == 'production'

  set :output, standard: '/var/log/cron.log', error: '/var/log/cron_error.log'

  job_type :rails_script, "cd /usr/src/app && ./rails_runner.sh ':task' :output"

  every :weekday, at: '6:00am' do
    rails_script 'GeckoboardPublisher::PhotoProfilesReport.new.publish!(true)'
  end

  every :weekday, at: '6:10am' do
    rails_script 'GeckoboardPublisher::ProfilesPercentageReport.new.publish!(true)'
  end

  every :weekday, at: '6:20am' do
    rails_script 'GeckoboardPublisher::TotalProfilesReport.new.publish!(true)'
  end

  every :weekday, at: '6:30am' do
    rails_script 'GeckoboardPublisher::ProfilesChangedReport.new.publish!(true)'
  end

  every :weekday, at: '6:40am' do
    rails_script 'GeckoboardPublisher::ProfileCompletionsReport.new.publish!(true)'
  end

  every :weekday, at: '7:00am' do
    rails_script 'CsvPublisher::UserBehaviorReport.publish!'
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

  every 5.minutes do
    rails_script 'NotificationSender.new.send!'
  end

end

if %w(dev demo staging).include? ENV['ENV']

  set :output, standard: '/var/log/cron.log', error: '/var/log/cron_error.log'

  job_type :rails_script, "cd /usr/src/app && ./rails_runner.sh ':task' :output"

  every 5.minutes do
    rails_script 'NotificationSender.new.send!'
  end

end
