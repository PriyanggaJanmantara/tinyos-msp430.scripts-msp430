#!/bin/sh -xu

prefix=/stow
urlbase=http://homepages.xnet.co.nz/~dlbeer
builddir=build-mspdebug

function die() {
    echo "$@" 1>&2
    exit 1
}

[ -f mspdebug.c ] \
    || curl -O $urlbase/mspdebug.c \
    || die "can not fetch source file"
which -s libusb-config \
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

