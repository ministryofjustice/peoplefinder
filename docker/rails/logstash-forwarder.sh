#!/bin/bash
cat <<EOT
{
  "network": {
     "servers": [ "$LOGSTASH_SERVER" ],
     "timeout": 15,
     "ssl certificate": "/etc/certs/server.crt",
     "ssl key": "/etc/certs/server.key",
     "ssl ca": "/etc/certs/server.crt"
  },
  "files": [
    {
      "paths": [ "/rails/log/unicorn.log" ],
      "fields": {
        "project": "$PROJECT",
        "appserver": "rails",
        "version": "$APPVERSION",
        "env": "$ENV"
      }
    },
    {
      "paths": [ "/rails/log/production.log" ],
      "fields": {
        "project": "$PROJECT",
        "appserver": "rails",
        "version": "$APPVERSION",
        "env": "$ENV"
      }
    },
    {
      "paths": [ "/rails/log/logstash_production.json" ],
      "fields": {
        "format": "json",
        "project": "$PROJECT",
        "appserver": "rails",
        "version": "$APPVERSION",
        "env": "$ENV"
      }
    }
  ]
}
EOT
