#!/bin/bash

# Release lrose-elle image (push to dockerhub)
# Bruno Melli 04-13-08
# 
# REMEMBER! to set the current version in the file VERSION
#

USERNAME=leavesntwigs
ORGANIZATION=nsflrose
IMAGE=lrose-elle

# Get version
version=`cat VERSION`

docker tag $ORGANIZATION/$IMAGE:$version $ORGANIZATION/$IMAGE:latest

# push it
docker push $ORGANIZATION/$IMAGE:$version
docker push $ORGANIZATION/$IMAGE:latest
