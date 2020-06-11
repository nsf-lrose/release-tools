#!/bin/bash

# Build script for lrose-elle docker images
# pulls from the top of the master branch of github repositories
# Bruno Melli 10-03-2019
# Brenda Javornik 12-24-2019
# Brenda Javornik 05-19-2020

USERNAME=mjskier
ORGANIZATION=nsflrose
IMAGE=lrose-elle
ubuntu=16.04

while getopts "u:ht:" opt; do
    case ${opt} in
        u ) ubuntu=${OPTARG}
            ;;
        h ) echo "Usage: $0 [-h] [-u <ubuntu release (default 16.04>]"
            exit 0
            ;;
        t ) tag=${OPTARG}
            ;;
    esac
done

VERSION=`date +%Y%m%d`
echo "$VERSION_ubuntu_$ubuntu" > VERSION

if [[ ! -r checkout_and_build_auto.py ]]; then
    wget "https://raw.githubusercontent.com/NCAR/lrose-core/master/build/checkout_and_build_auto.py"
fi

if [[ ! -r checkout_and_build_auto.py ]]; then
    echo "Could not fetch checkout_and_build_auto.py"
    echo "Try to get it by hand and rerun"
    exit 1
else
    chmod +x checkout_and_build_auto.py
fi

docker build -f "Dockerfile_centos_7_debug" -t $ORGANIZATION/$IMAGE:$VERSION --build-arg RELEASE_DATE=$tag .

# docker build -f "Dockerfile_latest_$ubuntu" -t $ORGANIZATION/$IMAGE:$VERSION --build-arg RELEASE_DATE=$tag .

# lrose-elle-20200519 .
