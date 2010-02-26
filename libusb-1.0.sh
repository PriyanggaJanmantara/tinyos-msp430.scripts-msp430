#!/bin/bash -xu

scriptdir=$(dirname $0)
. $scriptdir/config.sh

which libusb-config >/dev/null && exit 0

builddir=build-libusb
[[ -d libusb-1.0 ]] || git clone $repolibusb libusb-1.0

rm -rf $builddir
cp -R libusb-1.0 $builddir

cd $builddir
./autogen.sh
./configure --prefix=$prefix --disable-nls
make
# sudo make install
