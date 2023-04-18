#!/bin/sh

gem install eventmachine -v 1.0.5 -- --with-cppflags=-I/usr/local/opt/openssl/include

# fix for Nokogiri on arm64; helps to install platform agnostic/specific software
if [ $(arch | sed s/aarch64/arm64/) == 'arm64' ]; then
  bundle config set force_ruby_platform true
fi

bundler install

# Make these available via Settings in the app
export SETTINGS__GIT_COMMIT="$APP_GIT_COMMIT"
export SETTINGS__BUILD_DATE="$APP_BUILD_DATE"
export SETTINGS__GIT_SOURCE="$APP_BUILD_TAG"

mkdir -p log

set -ex

bundle exec rake db:setup
bundle exec rake peoplefinder:db:reload

