#!/bin/bash

# Build script for lrose-blaze
# Bruno Melli 04-13-08

USERNAME=mjskier
ORGANIZATION=nsflrose
IMAGE=lrose-blaze
ubuntu=16.04

while getopts "u:h" opt; do
    case ${opt} in
        u ) ubuntu=${OPTARG}
            ;;
        h ) echo "Usage: $0 [-h] [-u <ubuntu release (default 16.04>]"
            exit 0
            ;;
    esac
done

VERSION=`date +%m%d%Y`
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

docker build -f "Dockerfile_$ubuntu" -t $ORGANIZATION/$IMAGE:latest .
