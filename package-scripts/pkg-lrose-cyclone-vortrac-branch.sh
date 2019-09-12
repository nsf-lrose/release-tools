#!/bin/bash

# Build the lrose-cyclone packege (.tgz file)  
# - Grab the linux source release of lrose-cyclone
# - untar it
# - add the samurai, fractl, and vortrac (branch) sources (with the given tag)
# - repack everything
# - generate a lrose-cyclone.rb formula

# Bruno Melli 7/25/19
# Brenda Javornik 9/12/2019

RELEASE_DATE=20190910
LROSE_CORE_RELEASE_DATE=20190801
ADD_ON_RELEASE_DATE=20190726
tag=""
branch=""
buildDir="package_cyclone.$$"
# DEST=/Applications/MAMP/htdocs/testing/
DEST=/tmp/ 
TARFILE=lrose-cyclone-$RELEASE_DATE-vortrac-build-changes.tgz
TARGET=$DEST/$TARFILE

while getopts "b:t:h" opt; do
    case ${opt} in
        b ) branch=${OPTARG}
            ;;
        t ) tag=${OPTARG}
            ;;
        h ) echo "Usage: $0 [-h] [-t <tag>]"
            ;;
    esac
done

if [[ ! -z "$tag" ]] && [[ ! -z "$branch" ]]; then
    echo "-E- options -t -and -b are mutually exclusive"
    exit 1
fi

if [[ -z "$tag" ]] && [[ -z "$branch" ]]; then
    tag=lrose-cyclone-$ADD_ON_RELEASE_DATE
fi

echo "tag is ", $tag

cd /tmp
rm -rf $buildDir
mkdir $buildDir
cd $buildDir

# First get the lrose-cyclone release (subset of lrose-core)

wget https://github.com/NCAR/lrose-core/releases/download/lrose-cyclone-$LROSE_CORE_RELEASE_DATE/lrose-cyclone-$LROSE_CORE_RELEASE_DATE.src.tgz

tar zxf lrose-cyclone-$LROSE_CORE_RELEASE_DATE.src.tgz
rm lrose-cyclone-$LROSE_CORE_RELEASE_DATE.src.tgz

cd lrose-cyclone-$LROSE_CORE_RELEASE_DATE.src

# Grab addons from mmbell

for tool in samurai fractl; do
    git clone "https://github.com/mmbell/${tool}.git"
    cd $tool
    if [ ! -z "$tag" ]; then
	git checkout -q "$tag"
    fi
    rm -rf .git
    cd ..
done

# clone vortrac and switch to vortrac special branch 

git clone "https://github.com/mmbell/vortrac.git"
cd vortrac 
# git checkout $BRANCH 
git checkout -q build_changes 
rm -rf .git
cd ..
#   end special for vortrac branch

cd .. 
tar zcf $TARGET lrose-cyclone-$LROSE_CORE_RELEASE_DATE.src

#  Move all of the rest to CircleCI script ...

