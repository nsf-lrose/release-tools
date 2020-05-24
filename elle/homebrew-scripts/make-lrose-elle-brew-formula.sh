#!/bin/bash

# Build the lrose-elle homebrew formula
# - Grab the mac source release of lrose-elle
# - untar it
# - add the samurai, fractl, and vortrac sources (with the given tag)
# - repack everything
# - generate a lrose-elle.rb formula

# Bruno Melli 7/25/19
# Brenda Javornik 5/23/2020

# TODO
# Figure out what to set LROSE_ROOT_DIR while brew is
# building fractl and samurai, but before ose-elle has been installed
# in /usr/local

echo "Generating lrose-elle.rb"

cat <<EOF > lrose-elle.rb

require 'formula'

class LroseElle < Formula
  env :std
  homepage 'https://github.com/mmbell/samurai'

  url '$URL'
  version '$RELEASE_DATE'
  sha256 '$checksum'

  depends_on 'cmake'
  depends_on 'eigen'
  depends_on 'fftw'
  depends_on 'geographiclib'
  depends_on 'libomp'
  depends_on 'hdf5' => 'enable-cxx'
  depends_on 'jpeg'
  depends_on 'netcdf' => 'enable-cxx-compat'
  depends_on 'pkg-config'
  depends_on 'qt'
  depends_on 'szip'
  depends_on 'udunits'
  depends_on 'armadillo'
  depends_on 'rsync'
  depends_on 'libzip'
  depends_on :x11

  def install

    ENV["PKG_CONFIG_PATH"] = "/usr/local/opt/qt/lib/pkgconfig"
    # system "tar xf lrose-elle*.tgz"
    # Dir.chdir("lrose-elle*.mac_osx")
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
    Dir.chdir("vortrac/src")
    # ENV['PKG_CONFIG_PATH'] = "/usr/local/opt/qt/lib/pkgconfig"
    ENV['LROSE_ROOT_DIR'] = prefix
    ENV['LROSE_INSTALL_DIR'] = prefix
    ENV['RADX_INCLUDE'] = "#{prefix}/include"
    ENV['RADX_LIB'] = "#{prefix}/lib"
    ENV['ARMADILLO_INCLUDE'] = "`pkg-config --variable=includedir armadillo`"
    ENV['ARMADILLO_LIB'] = "`pkg-config --variable=libdir armadillo`"
    ENV['NETCDF_INCLUDE'] = "/usr/local/include"
    ENV['NETCDF_LIB'] = "/usr/local/lib"
    ENV['LD_LIBRARY_PATH'] = "#{prefix}/lib"
    system "qmake", "."
    system "make"
    bin.install 'vortrac.app/Contents/MacOS/vortrac'
    Dir.chdir("..")
    system "rsync", "-av", "Resources", "#{prefix}"
    Dir.chdir("..")
  end
 
  def test
    system "#{bin}/RadxPrint", "-h"
    system "#{bin}/samurai", "-h"
    system "#{bin}/fractl", "-h"
    system "#{bin}/vortrac", "-h"
  end
end

EOF

# mv lrose-elle.rb $DEST
