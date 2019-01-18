#!/bin/bash

# Build the lrose-blaze homebrew formula
# - Grab the mac source release of lrose-blaze
# - untar it
# - add the samurai and fractl sources (with the given tag)
# - repack everything
# - generate a lrose-blaze.rb formula

# Bruno Melli 1/9/19

# TODO
# Figure out what to set LROSE_ROOT_DIR while brew is
# building fractl and samurai, but before lr0se-blaze has been installed
# in /usr/local


tag=""
branch=""
buildDir="package_blaze.$$"
DEST=/Applications/MAMP/htdocs/testing/
TARFILE=lrose-blaze-20190104.homebrew.tgz
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
    tag=lrose-blaze-20190105
fi

cd /tmp
rm -rf $buildDir
mkdir $buildDir
cd $buildDir

# First get the lrose-blaze release (subset of lrose-core)

wget https://github.com/NCAR/lrose-core/releases/download/lrose-blaze-20190104/lrose-blaze-20190104.src.mac_osx.tgz

tar zxf lrose-blaze-20190104.src.mac_osx.tgz
rm lrose-blaze-20190104.src.mac_osx.tgz

cd lrose-blaze-20190104.src.mac_osx

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

cd .. 
tar zcf $TARGET lrose-blaze-20190104.src.mac_osx

checksum=`sha256sum $TARGET | awk '{ print $1; }'`

URL="http://mistral.atmos.colostate.edu/testing/$TARFILE"
echo "Generating lrose-blaze.rb"

cat <<EOF > lrose-blaze.rb

require 'formula'

class LroseBlaze < Formula
  env :std
  homepage 'https://github.com/mmbell/samurai'

  url '$URL'
  version '20190104'
  sha256 '$checksum'

  depends_on 'cmake'
  depends_on 'eigen'
  depends_on 'fftw'
  depends_on 'flex'
  depends_on 'geographiclib'
  depends_on 'hdf5' => 'enable-cxx'
  depends_on 'jasper'
  depends_on 'jpeg'
  depends_on 'netcdf' => 'enable-cxx-compat'
  depends_on 'pkg-config'
  depends_on 'qt'
  depends_on 'szip'
  depends_on 'udunits'
  depends_on :x11

  def install
    # This is the lrose-blaze subset of lrose-core

    ENV["PKG_CONFIG_PATH"] = "/usr/local/opt/qt/lib/pkgconfig"
    Dir.chdir("codebase")
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
    Dir.chdir("..")
    system "rsync", "-av", "share", "#{prefix}"

    # Build/install samurai
    Dir.chdir("samurai")
    ENV['LROSE_ROOT_DIR'] = prefix
    system "cmake", "."
    system "make", "VERBOSE=1"
    bin.install 'build/release/bin/samurai'
    lib.install 'build/release/lib/libsamurai.a'
    lib.install 'build/release/lib/libsamurai.dylib'
    include.install 'src/samurai.h'

    # Build/install fractl
    Dir.chdir("fractl")
    ENV['LROSE_ROOT_DIR'] = prefix
    system "cmake", "."
    system "make"
    bin.install 'build/release/bin/fractl'
  end
 
  def test
    system "#{bin}/RadxPrint", "-h"
    system "#{bin}/samurai", "-h"
    system "#{bin}/fractl", "-h"
  end
end

EOF

mv lrose-blaze.rb $DEST
