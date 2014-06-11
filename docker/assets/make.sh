#!/bin/bash

DOCKERFILE="docker/assets/Dockerfile"
DOCKERTAG=assets

[ ! -d "docker" ] && echo "Please run from git root" && exit 1

cp ${DOCKERFILE} .
docker build -t assets --force-rm=true .
