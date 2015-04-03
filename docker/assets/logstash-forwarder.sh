#!/bin/bash

# Set variables to unknown if not defined
PROJECT=${PROJECT:-pq}
ENV=${ENV:-unknown}
APPVERSION=${APPVERSION:-unknown}

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
      "paths": [ "/var/log/nginx/access.json" ],
      "fields": {
        "project": "$PROJECT",
        "appserver": "assets",
        "version": "$APPVERSION",
        "env": "$ENV",
        "format": "json"
      }
    },
    {
      "paths": [ "/var/log/nginx/error.log" ],
      "fields": {
        "project": "$PROJECT",
        "appserver": "assets",
        "version": "$APPVERSION",
        "env": "$ENV"
      }
    }
  ]
}
EOT

