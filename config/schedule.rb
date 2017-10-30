if ENV['ENV'] == 'production'

  set :output, standard: '/var/log/cron.log', error: '/var/log/cron_error.log'

  job_type :rails_script, "cd /home/vcap/app && ./rails_runner.sh ':task' :output"
  job_type :rake_task, 'cd /home/vcap/app && :environment_variable=:environment bundle exec rake :task --silent :output'

  every 5.minutes do
    rails_script 'NotificationSender.new.send!'
  end

  every 1.day, at: '4:30 am' do
    rake 'db:sessions:trim'
  end
end

if %w(dev demo staging).include? ENV['ENV']

  set :output, standard: '/var/log/cron.log', error: '/var/log/cron_error.log'

  job_type :rails_script, "cd /usr/src/app && ./rails_runner.sh ':task' :output"

  every 5.minutes do
    rails_script 'NotificationSender.new.send!'
  end

end
