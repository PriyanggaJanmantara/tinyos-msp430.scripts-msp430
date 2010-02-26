#!/bin/sh

scriptdir=$(dirname $0)
prefix=/stow
cvsroot=:pserver:anonymous@mspgcc.cvs.sourceforge.net:/cvsroot/mspgcc
builddir=build-msp430-libc

function die() {
    echo "$@" 1>&2
    exit 1
}

[ -f $scriptdir/msp430-libc.patch ] \
    || die $scriptdir/msp430-libc.patch is missing
[ -d mspgcc-msp430-libc ] \
    || cvs -d $cvsroot co -d mspgcc-msp430-libc -P msp430-libc \
    || die "can not fetch cvs repository"

rm -rf $builddir
cp -R mspgcc-msp430-libc $builddir
patch -p1 -d $builddir < $scriptdir/msp430-libc.patch \
    || die "apply patch failed"

cd $builddir/src
make -j32
# sudo make install
