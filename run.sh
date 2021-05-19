#!/bin/sh

ROLE="${1:-app}"

case ${DOCKER_STATE} in
migrate)
    echo "running migrate"
    bundle exec rake db:migrate
    ;;
esac

case ${ROLE} in
worker)
    echo 'exporting non-language env vars to cron available environment'
    env | grep -ve LANG -ve LC_ >> '/etc/environment'

    echo 'exporting language vars to default locale'
    env | grep -e LANG -e LC_ >> '/etc/default/locale'

    echo 'writing rails runner script'
    echo '#!/bin/bash' > rails_runner.sh
    PATH_APPENDS='PATH=/usr/local/bundle/bin:$PATH GEM_HOME=/usr/local/bundle GEM_PATH=/usr/local/bundle:$GEM_PATH'
    echo "cd /usr/src/app && $PATH_APPENDS bin/rails runner -e production \$1" >> rails_runner.sh
    chmod a+x rails_runner.sh

    echo "running worker"
    bundle exec rake jobs:work
    ;;
*)
    echo "running app server - unicorn"
    bundle exec unicorn -c config/unicorn.rb -p $UNICORN_PORT
    ;;
esac
