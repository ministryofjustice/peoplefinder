#!/bin/sh
set +ex

RAILS_ENV=production bin/delayed_job run
