#!/bin/bash -xu

scriptdir=$(dirname $0)
. $scriptdir/config.sh

builddir=build-mspdebug

[[ -d $mspdebug.tar.gz ]] \
    || $fetch $urlmspdebug/$mspdebug.tar.gz \
    || die "can not fetch source file"
which libusb-config >/dev/null \
    || die "libusb is not installed"

rm -rf $builddir
tar xf $mspdebug.tar.gz
mv $mspdebug $builddir

is_osx && CFLAGS=-D'usb_detach_kernel_driver_np(x,y)'=0 || CFLAGS=
cd $builddir
make
# sudo cp -p mspdebug $prefix/bin

