#!/bin/bash

DOCKERFILE="docker/assets/Dockerfile"
DOCKERREPO="docker.local:5000"
DOCKERTAG=assets

[ ! -d "docker" ] && echo "Please run from git root" && exit 1

if [ -n "$1" ]; then 
  TAG="${DOCKERREPO}/${DOCKERTAG}:$1"
else 
  TAG="${DOCKERREPO}/${DOCKERTAG}"
fi

cp ${DOCKERFILE} .
docker build -t ${TAG} --force-rm=true .

echo "+ docker push ${TAG}"
docker push ${TAG}
echo "+ docker rmi ${TAG}"
docker rmi ${TAG}


