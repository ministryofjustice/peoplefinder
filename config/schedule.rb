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
