#!/bin/sh

prefix=/stow
urlbase=http://homepages.xnet.co.nz/~dlbeer
builddir=build-mspdebug

function die() {
    echo "$@" 1>&2
    exit 1
}

[ -f mspdebug.c ] || curl -O $urlbase/mspdebug.c
which -s libusb-config || die "libusb is not installed"

rm -rf $builddir
mkdir -p $builddir
cp -p mspdebug.c $builddir

cd $builddir
gcc -c mspdebug.c -O $(libusb-config --cflags)
gcc -o mspdebug mspdebug.o $(libusb-config --libs)
# sudo cp -p mspdebug $prefix/bin

