#!/bin/bash -xu

scriptdir=$(dirname $0)
. $scriptdir/config.sh

builddir=build-mspdebug

[[ -f $mspdebug.tar.gz ]] \
    || $fetch $urlmspdebug/$mspdebug.tar.gz \
    || die "can not fetch source file"

libusb=$(which libusb-legacy-config || which libusb-config) 
[[ -x $libusb ]] \
    || die "libusb is not installed"

rm -rf $builddir $mspdebug
tar xzf $mspdebug.tar.gz
mv $mspdebug $builddir

is_osx \
    && COMPAT_FLAGS="-D'usb_detach_kernel_driver_np(x,y)'=0 -DB460800=460800 -I/opt/local/include" \
    || COMPAT_FLAGS=

is_osx && test -f $scriptdir/$mspdebug-osx_*.patch \
    && patch -d $builddir -p1 < $scriptdir/$mspdebug-osx_*.patch
    
cd $builddir
make -j$(num_cpus) \
    CFLAGS+="$COMPAT_FLAGS" CFLAGS+=$($libusb --cflags) CFLAGS+=$($libusb --libs)
# sudo cp -p mspdebug $prefix/bin

