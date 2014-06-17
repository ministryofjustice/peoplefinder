#!/bin/bash

DOCKERFILE="docker/rails/Dockerfile"
DOCKERTAG=rails

[ ! -d "docker" ] && echo "Please run from git root" && exit 1

if [ -n "$1" ]; then
  TAG="${DOCKERREPO}/${DOCKERTAG}:$1"
else
  TAG="${DOCKERREPO}/${DOCKERTAG}"
fi

cp ${DOCKERFILE} .
docker build -t ${TAG} --force-rm=true .
docker push ${TAG}
docker rmi ${TAG}
