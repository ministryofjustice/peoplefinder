set :output, '/var/log/cron_log.log'

job_type :rails_script, "cd /usr/src/app && ./rails_runner.sh ':task' :output"

every :weekday, at: '8am' do
  rails_script 'NeverLoggedInNotifier.send_reminders'
end

every :weekday, at: '8:10am' do
  rails_script 'TeamDescriptionNotifier.send_reminders'
end

every :weekday, at: '8:15am' do
  rails_script 'PersonUpdateNotifier.send_reminders'
end

every :weekday, at: '8:00pm' do
  rails_script 'GeckoboardPublisher::PhotoProfilesReport.new.publish!'
end

every :weekday, at: '8:10pm' do
  rails_script 'GeckoboardPublisher::ProfilesPercentageReport.new.publish!'
end

every :weekday, at: '8:20pm' do
  rails_script 'GeckoboardPublisher::TotalProfilesReport.new.publish!'
end

every :weekday, at: '8:30pm' do
  rails_script 'GeckoboardPublisher::ProfilesChangedReport.new.publish!'
end
