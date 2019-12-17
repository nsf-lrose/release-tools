#!/bin/bash

# Build the lrose-cyclone homebrew formula
# - Grab the mac source release of lrose-cyclone
# - untar it
# - add the samurai, fractl, and vortrac sources (with the given tag)
# - repack everything
# - generate a lrose-cyclone.rb formula

# Bruno Melli 7/25/19

# TODO
# Figure out what to set LROSE_ROOT_DIR while brew is
# building fractl and samurai, but before ose-cyclone has been installed
# in /usr/local

#RELEASE_DATE=20190910
#LROSE_CORE_RELEASE_DATE=20190801
#ADD_ON_RELEASE_DATE=20190726
#tag=""
#branch=""
#buildDir="package_cyclone.$$"
## DEST=/Applications/MAMP/htdocs/testing/
#DEST=/tmp/ 
#TARFILE=lrose-cyclone-$RELEASE_DATE.homebrew.tgz
#TARGET=$DEST/$TARFILE

#while getopts "b:t:h" opt; do
#    case ${opt} in
#        b ) branch=${OPTARG}
#            ;;
#        t ) tag=${OPTARG}
#            ;;
#        h ) echo "Usage: $0 [-h] [-t <tag>]"
#            ;;
#    esac
#done

#if [[ ! -z "$tag" ]] && [[ ! -z "$branch" ]]; then
#    echo "-E- options -t -and -b are mutually exclusive"
#    exit 1
#fi

#if [[ -z "$tag" ]] && [[ -z "$branch" ]]; then
#    tag=lrose-cyclone-$ADD_ON_RELEASE_DATE
#fi
#
#echo "tag is ", $tag


#rm -rf $buildDir
#mkdir $buildDir
#cd $buildDir

# First get the lrose-cyclone release (subset of lrose-core)

#wget https://github.com/NCAR/lrose-core/releases/download/lrose-cyclone-$LROSE_CORE_RELEASE_DATE/lrose-cyclone-$LROSE_CORE_RELEASE_DATE.src.mac_osx.tgz

#tar zxf lrose-cyclone-$LROSE_CORE_RELEASE_DATE.src.mac_osx.tgz
#rm lrose-cyclone-$LROSE_CORE_RELEASE_DATE.src.mac_osx.tgz
#
#cd lrose-cyclone-$LROSE_CORE_RELEASE_DATE.src.mac_osx

# Grab addons from mmbell

#for tool in samurai fractl vortrac; do
#    git clone "https://github.com/mmbell/${tool}.git"
#    cd $tool
#    if [ ! -z "$tag" ]; then
#	git checkout -q "$tag"
#    fi
#    rm -rf .git
#    cd ..
#done

#cd .. 
#tar zcf $TARGET lrose-cyclone-$LROSE_CORE_RELEASE_DATE.src.mac_osx
#
# TODO: set environment variables before calling script
# TARGET
# URL
# RELEASE_DATE
# DEST

# checksum=`sha256sum $TARGET | awk '{ print $1; }'`

# URL="http://mistral.atmos.colostate.edu/testing/$TARFILE"
# URL="https://github.com/NCAR/lrose-release-test/releases/download/testing/$TARFILE"
echo "Generating lrose-cyclone.rb"

cat <<EOF > lrose-cyclone.rb

require 'formula'

class LroseCyclone < Formula
  env :std
  homepage 'https://github.com/mmbell/samurai'

  url '$URL'
  version '$RELEASE_DATE'
  sha256 '$checksum'

  depends_on 'cmake'
  depends_on 'eigen'
  depends_on 'fftw'
  # depends_on 'flex'
  depends_on 'geographiclib'
  depends_on 'libomp'
  depends_on 'hdf5' => 'enable-cxx'
  # depends_on 'jasper'
  depends_on 'jpeg'
  depends_on 'netcdf' => 'enable-cxx-compat'
  depends_on 'pkg-config'
  depends_on 'qt'
  depends_on 'szip'
  depends_on 'udunits'
  depends_on 'armadillo'
  depends_on 'rsync'
  depends_on 'libzip'
  # depends_on :x11

  def install

    ENV["PKG_CONFIG_PATH"] = "/usr/local/opt/qt/lib/pkgconfig"
    # system "tar xf lrose-cyclone*.tgz"
    # Dir.chdir("lrose-cyclone*.mac_osx")
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
    #Dir.chdir("..")
    system "rsync", "-av", "share", "#{prefix}"

    # Build/install fractl
    Dir.chdir("fractl")
    ENV['LROSE_ROOT_DIR'] = prefix
    system "cmake", "."
    system "make"
    bin.install 'build/release/bin/fractl'
    Dir.chdir("..")

    # Build/install samurai
    Dir.chdir("samurai")
    ENV['LROSE_ROOT_DIR'] = prefix
    system "cmake", "."
    system "make", "VERBOSE=1"
    bin.install 'build/release/bin/samurai'
    lib.install 'build/release/lib/libsamurai.a'
    lib.install 'build/release/lib/libsamurai.dylib'
    include.install 'src/samurai.h'
    Dir.chdir("..")

    # Build/install vortrac
    #Dir.chdir("vortrac/src")
    #ENV['LROSE_ROOT_DIR'] = prefix
    #ENV['NETCDF_INCLUDE'] = "#{prefix}/include"
    #ENV['NETCDF_LIB'] = "#{prefix}/lib"
    #system "qmake", "."
    #system "make"
    #bin.install 'vortrac.app/Contents/MacOS/vortrac'
    #Dir.chdir("..")
    #system "rsync", "-av", "Resources", "#{prefix}"
    #Dir.chdir("..")
  end
 
  def test
    system "#{bin}/RadxPrint", "-h"
    system "#{bin}/samurai", "-h"
    system "#{bin}/fractl", "-h"
    # system "#{bin}/vortrac", "-h"
  end
end

EOF

# mv lrose-cyclone.rb $DEST
