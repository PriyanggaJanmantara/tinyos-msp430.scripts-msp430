#!/bin/bash -xu

scriptdir=$(dirname $0)
. $scriptdir/config.sh

builddir=build-mspdebug

[[ -f mspdebug.c ]] \
    || $fetch $urlmspdebug/mspdebug.c \
    || die "can not fetch source file"
which libusb-config >/dev/null \
    || die "libusb is not installed"

rm -rf $builddir
mkdir -p $builddir
cp -p mspdebug.c $builddir

cd $builddir
gcc -c mspdebug.c -O $(libusb-config --cflags) \
    || die "can not compile"
gcc -o mspdebug mspdebug.o $(libusb-config --libs) \
    || die "can not link"
# sudo cp -p mspdebug $prefix/bin

