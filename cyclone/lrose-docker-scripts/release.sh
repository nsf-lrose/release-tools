#!/bin/bash

# Release lrose-cyclone image (push to dockerhub)
# Bruno Melli 04-13-08

USERNAME=mjskier
ORGANIZATION=nsflrose
IMAGE=lrose-cyclone

# Get version
version=`cat VERSION`

docker tag $ORGANIZATION/$IMAGE:latest $ORGANIZATION/$IMAGE:$version

# push it
docker push $ORGANIZATION/$IMAGE:$version
docker push $ORGANIZATION/$IMAGE:latest
