#!/bin/sh

if ! bundle show puma > /dev/null 2>&1; then
  printf '\e[33mPuma server could not be started.\e[0m\n'
  printf '\e[33mThis is likely an issue with our bundle install script; /usr/bin/install.sh\e[0m\n'
  exit 0
fi

printf "\n\e[32m***> \e[0mConnection details"
printf '\n\e[32m*****> \e[0m\e[33mAPP: http://%s/\e[0m' "$PF_HOST_NAME"
printf '\n\e[32m*****> \e[0m\e[33mMAIL: http://%s/\e[0m' "mail.$PF_HOST_NAME"
printf '\n\e[32m*****> \e[0m\e[33mKIBANA: http://%s/\e[0m' "kibana.$PF_HOST_NAME"
printf '\n\e[32m*****> \e[0m\e[33mPGAdmin4: http://%s/\e[0m\n\n\n' "$PF_HOST_NAME:5050"

printf '\e[33mINFO: Launching Puma\e[0m\n'
bundle exec puma -C config/puma.rb
