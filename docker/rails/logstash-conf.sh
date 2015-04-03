#!/bin/bash
for i in /rails/log/unicorn.log /rails/log/production.log /rails/log/logstash_production.json;
  do touch $i
done

cat <<EOT

  input {
    file {
      path => "/rails/log/unicorn.log"
      type => "rails"
      add_field => [ "project",   "$PROJECT" ]
      add_field => [ "appserver", "rails" ]
      add_field => [ "version",   "$APPVERSION" ]
      add_field => [ "env",       "$ENV" ]
    }
    file {
      path => "/rails/log/production.log"
      type => "rails"
      add_field => [ "project",   "$PROJECT" ]
      add_field => [ "appserver", "rails" ]
      add_field => [ "version",   "$APPVERSION" ]
      add_field => [ "env",       "$ENV" ]
    }
    file {
      path  => "/rails/log/logstash_production.json"
      type  => "rails"
      codec => "json"
      add_field => [ "project",   "$PROJECT" ]
      add_field => [ "appserver", "rails" ]
      add_field => [ "version",   "$APPVERSION" ]
      add_field => [ "env",       "$ENV" ]
      add_field => [ "format",    "json" ]
    }
  }
  output {
    redis { host => "$LOGSTASH_SERVER" data_type => "list" key => "logstash" }
  }

EOT

