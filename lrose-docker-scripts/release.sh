#!/bin/bash

# Release lrose-blaze image (push to dockerhub)
# Bruno Melli 04-13-08

USERNAME=mjskier
ORGANIZATION=nsflrose
IMAGE=lrose-blaze

# Get version
version=`cat VERSION`

docker tag $ORGANIZATION/$IMAGE:latest $ORGANIZATION/$IMAGE:$version

# push it
docker push $ORGANIZATION/$IMAGE:$version
docker push $ORGANIZATION/$IMAGE:latest
