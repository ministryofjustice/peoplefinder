#!/usr/bin/env bash

ROLE="${1:-app}"

case ${DOCKER_STATE} in
migrate)
    echo "running migrate"
    bundle exec rake db:migrate
    ;;
esac

case ${ROLE} in
worker)
    # echo "creating rails_runner.sh for running rails runners via a cron job"
    # env > env.sh

    # echo 'deleting certain env vars - not necessary'
    # sed -i '/ADMIN_IP_RANGES.*/d' env.sh
    # sed -i '/NEW_RELIC_APP_NAME.*/d' env.sh

    echo 'exporting env vars to cron available environment'
    env >> '/etc/environment'

    echo '#!/bin/bash' > rails_runner.sh
    echo "cd /usr/src/app" >> rails_runner.sh

    PATH_APPENDS='PATH=/usr/local/bundle/bin:$PATH GEM_HOME=/usr/local/bundle GEM_PATH=/usr/local/bundle:$GEM_PATH'
    # echo "cd /usr/src/app && $(cat env.sh | xargs) $PATH_APPENDS bin/rails runner -e production \$1" >> rails_runner.sh
    echo "cd /usr/src/app && $PATH_APPENDS bin/rails runner -e production \$1" >> rails_runner.sh
    chmod a+x rails_runner.sh

    echo "installing cron"
    apt-get update && apt-get install -y cron

    echo "starting cron"
    service cron start

    echo "running whenever to create/update crontab"
    bundle exec whenever -w

    echo "running worker"
    bundle exec rake jobs:work
    ;;
*)
    echo "running app server - unicorn"
    bundle exec unicorn -c config/unicorn.rb -p $UNICORN_PORT
    ;;
esac
