#!/bin/sh
set +ex

# Make these available via Settings in the app
export SETTINGS__GIT_COMMIT="$APP_GIT_COMMIT"
export SETTINGS__BUILD_DATE="$APP_BUILD_DATE"
export SETTINGS__GIT_SOURCE="$APP_BUILD_TAG"


bundle exec rails db:migrate

set -ex

printf '\e[33mINFO: Launching Puma\e[0m\n'
bundle exec puma -C config/puma.rb -e production
