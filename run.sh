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
    echo "running worker"
    bundle exec rake jobs:work
    ;;
*)
    echo "running app"
    bundle exec unicorn -c config/unicorn.rb -p $UNICORN_PORT
    ;;
esac
