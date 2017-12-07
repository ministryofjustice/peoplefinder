web: bundle exec rake db:migrate && unicorn -p $PORT -c ./config/unicorn.rb
worker: bundle exec rake jobs:work