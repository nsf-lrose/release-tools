#!/bin/bash

# Package the samurai source tree into a .tgz and a matching samurai.rb
# brew formula suitable to be installed with
#    brew install ./samurai.rb.rb
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

if [[ ! -z "$tag" ]] && [[ ! -z "$branch" ]]; then
    echo "-E- options -t -and -b are mutually exclusive"
    exit 1
fi

release=${release:-`date +"%Y%m%d"`}

SNAPSHOT=samurai-${release}.homebrew
DEST=/Applications/MAMP/htdocs/testing/
TARGET=${DEST}/$SNAPSHOT.tgz
URL="${repo}/$SNAPSHOT.tgz"

# Grab the source

cd /tmp
rm -rf samurai "$SNAPSHOT"
git clone https://github.com/mmbell/samurai.git

# Switch to a tag/branch if requested

if [ ! -z "$branch" ]; then
    echo "-I- Checking out branch $branch"
    cd "samurai"
    git checkout -q $branch
    cd ..
fi

if [ ! -z "$tag" ]; then
    echo "-I- Checking out tag $tag"    
    cd samurai
    git checkout -q $tag
    cd ..
fi

rsync -avz --exclude .git /tmp/samurai/* /tmp/$SNAPSHOT
rm -rf /tmp/samurai

(cd /tmp && tar zcf $TARGET $SNAPSHOT)

checksum=`sha256sum $TARGET | awk '{ print $1; }'`

echo "-I- Generating samurai.rb"

cat <<EOF > samurai.rb
require 'formula'

class Samurai < Formula
  env :std
  homepage 'https://github.com/mmbell/samurai'

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
  depends_on 'libomp'
  depends_on 'lrose-blaze'
  depends_on 'qt'
  depends_on :x11

  def install
    ENV['LROSE_ROOT_DIR'] = '/usr/local'
    system "cmake", "."
    system "make", "VERBOSE=1"
    bin.install 'build/release/bin/samurai'
    lib.install 'build/release/lib/libsamurai.a'
    lib.install 'build/release/lib/libsamurai.dylib'
    include.install 'src/samurai.h'
  end

  def test
    system "#{bin}/samurai", "-h"
  end
end
EOF

mv samurai.rb $DEST
rm -rf "$SNAPSHOT"
