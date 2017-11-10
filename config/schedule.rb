if ENV['ENV'] == 'production'

  set :output, standard: '/var/log/cron.log', error: '/var/log/cron_error.log'

  job_type :rake_task, 'cd /home/vcap/app && :environment_variable=:environment bundle exec rake :task --silent :output'

  every 1.day, at: '4:30 am' do
    rake 'db:sessions:trim'
  end
end
