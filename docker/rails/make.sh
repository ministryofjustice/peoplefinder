#!/bin/bash

DOCKERFILE="docker/rails/Dockerfile"
DOCKERTAG=rails

[ ! -d "docker" ] && echo "Please run from git root" && exit 1

cp ${DOCKERFILE} .
docker build -t rails --force-rm=true .
