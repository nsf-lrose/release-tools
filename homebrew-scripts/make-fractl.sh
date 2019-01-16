#!/bin/bash

# Package the fractl source tree into a .tgz and a matching fractl.rb
# brew formula suitable to be installed with
#    brew install ./fractl.rb
#
# An optional branch or tag can be specified.
# Unless specified, the release will be tagged with today's date
#
# Bruno Melli 1/10/19

tag=""
branch=""
release=""
dir=`pwd`
repo=https://github.com/nsf-lrose/lrose-blaze/releases/download/lrose-blaze-20190105

while getopts "b:t:r:hl" opt; do
    case ${opt} in
	b ) branch=${OPTARG}
	    ;;
	t ) tag=${OPTARG}
	    ;;
	r ) release=${OPTARG}
	    ;;
	l ) repo="http://mistral.atmos.colostate.edu/testing"
	    ;;
	h ) echo "Usage: $0 [-h] [-t <tag>] [-r <release>]"
	    exit 0
	    ;;
    esac
done

release=${release:-`date +"%Y%m%d"`}

if [[ ! -z "$tag" ]] && [[ ! -z "$branch" ]]; then
    echo "-E- options -t -and -b are mutually exclusive"
    exit 1
fi

SNAPSHOT=fractl-${release}.homebrew
DEST=/Applications/MAMP/htdocs/testing/
TARGET=${DEST}/$SNAPSHOT.tgz
URL="${repo}/$SNAPSHOT.tgz"

# Grab the source

cd /tmp
rm -rf fractl "$SNAPSHOT"
git clone https://github.com/mmbell/fractl.git

# Switch to a tag/branch if requested

if [ ! -z "$branch" ]; then
    echo "-I- Checking out branch $branch"
    cd FRACTL
    git checkout -q $branch
    cd ..
fi

if [ ! -z "$tag" ]; then
    echo "-I- Checking out tag $tag"    
    cd fractl
    git checkout -q $tag
    cd ..
fi

rsync -avz --exclude .git /tmp/fractl/* /tmp/$SNAPSHOT
rm -rf /tmp/fractl

(cd /tmp && tar zcvf $TARGET $SNAPSHOT)

checksum=`sha256sum $TARGET | awk '{ print $1; }'`

echo "-I- Generating fractl.rb"

cat <<EOF > fractl.rb
require 'formula'

class Fractl < Formula
  homepage 'https://github.com/mmbell/FRACTL'

  url '$URL'
  version '$SNAPSHOT'
  sha256 '$checksum'

  depends_on 'hdf5' => 'enable-cxx'
  depends_on 'netcdf' => 'enable-cxx-compat'
  depends_on 'udunits'
  depends_on 'fftw'
  depends_on 'flex'
  depends_on 'libzip'
  depends_on 'pkg-config'
  depends_on 'cmake'
  depends_on 'geographiclib'
  depends_on 'eigen'
  depends_on 'lrose-blaze'

  def install
    ENV['LROSE_ROOT_DIR'] = '/usr/local'
    system "cmake", "."
    system "make"
    bin.install 'build/release/bin/fractl'
  end

  def test
    system "#{bin}/fractl", "-h"
  end
end
EOF

mv fractl.rb $DEST
rm -rf "$SNAPSHOT"
