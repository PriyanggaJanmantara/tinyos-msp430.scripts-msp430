#!/bin/sh -xu

prefix=/stow
giturl=git://git.libusb.org/libusb.git
builddir=build-libusb

[ -d libusb-1.0 ] || git clone $giturl libusb-1.0

rm -rf $builddir
cp -R libusb-1.0 $builddir

cd $builddir
./autogen.sh
./configure --prefix=$prefix --disable-nls
make -j32
# sudo make install
