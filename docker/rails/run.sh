#!/bin/bash

docker run -p 80 -p 22 -d rails  /sbin/my_init --enable-insecure-key
