#!/bin/bash
cat <<EOT

  input {
    file {
      path  => "/var/log/nginx/error.log"
      type  => "assets"
      add_field => [ "project",   "$PROJECT" ]
      add_field => [ "appserver", "assets" ]
      add_field => [ "version",   "$APPVERSION" ]
      add_field => [ "env",       "$ENV" ]
    }
    file {
      path  => "/var/log/nginx/access.json"
      type  => "assets"
      codec => "json"
      add_field => [ "project",   "$PROJECT" ]
      add_field => [ "appserver", "assets" ]
      add_field => [ "version",   "$APPVERSION" ]
      add_field => [ "env",       "$ENV" ]
      add_field => [ "format",    "json" ]
    }
  }
  output {
    redis { host => "$LOGSTASH_SERVER" data_type => "list" key => "logstash" }
  }

EOT

