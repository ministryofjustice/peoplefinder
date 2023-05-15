#!/bin/sh

bundle exec rails generate browser_sync_rails:install
bundle exec rails browser_sync:start
