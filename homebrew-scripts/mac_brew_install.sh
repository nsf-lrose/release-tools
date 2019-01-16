#!/bin/bash

# Grab and install the 3 homebrew components of the lrose-blaze release
# Bruno Melli 1/10/19

source=https://github.com/nsf-lrose/lrose-blaze/releases/download/lrose-blaze-20190105
tmp=/tmp/install_blaze.$$
packages="lrose-blaze samurai fractl"

# TODO: add a -r (release) option instead of hard coded lrose-blaze-20190105

while getopts "s:h" opt; do
    case ${opt} in
        s ) source=${OPTARG}
            ;;
	l ) source=http://mistral.atmos.colostate.edu/testing
	    ;;
        h ) echo "Usage: $0 [-h] [-s <source>]"
	    exit 0
            ;;
    esac
done

# First remove any existing installation
# Need to remove in reverse order to prevent dependencies

reverse=`echo $packages | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }'`

for formula in $reverse; do
    if brew ls --versions $formula > /dev/null; then
	echo "-I- Removing previously installed $formula"
	brew uninstall $formula
    fi
done

mkdir $tmp
cd $tmp

for formula in $packages; do
    echo "-I- Installing $formula"
    wget -q "$source/$formula.rb"
    if ! brew install "$formula.rb" 2>&1 > $formula.log; then
	echo "-E- Failed to install $formula. Exiting..."
	echo "-E- See $tmp/$formula.log"
	break
    fi
done

cd /
rm -rf $tmp
