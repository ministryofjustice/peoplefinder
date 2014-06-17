worker_processes 4

rails_env = 'production'
app_home = ENV['APP_HOME'] || '/home/vagrant/pq/current'

#listen "/home/vagrant/pq/shared/unicorn.sock", :backlog => 64
listen 3000
working_directory "#{app_home}"
pid "#{app_home}/log/unicorn.pid"
stderr_path "#{app_home}/log/unicorn.stderr.log"
stdout_path "#{app_home}/log/unicorn.stdout.log"

timeout 30
preload_app true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
