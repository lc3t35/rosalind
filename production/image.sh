#!/bin/bash

set -e

cd "$(dirname "$0")"

if [ ! -e ../build/bundle/package.json ]; then
  echo "** Skipping image build"
  echo "     Please make sure you run ./pack.sh"
  echo "     and build/bundle/package.json exists."
  exit 1
else

  if [ ! -z $CI ]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD -e $DOCKER_EMAIL $DOCKER_SERVER
  fi

  echo "** Building docker image"

  cp Dockerfile ../build/bundle/Dockerfile

  cd ../build/bundle/

  docker build -t $DOCKER_IMAGE .

  rm Dockerfile
  cd -

fi