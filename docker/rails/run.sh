#!/bin/bash

docker run -p 80 -p 22 --env LOGSTASH_SERVER=54.76.245.119:2510 --env GRAPHITE_SERVER=54.76.245.119 -d docker.local:5000/myrails /sbin/my_init --enable-insecure-key
