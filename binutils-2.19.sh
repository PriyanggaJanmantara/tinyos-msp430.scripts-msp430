#!/bin/sh

scriptdir=$(dirname $0)
prefix=/stow
binutils=binutils-2.19
cvsroot=:pserver:anonymous@mspgcc.cvs.sourceforge.net:/cvsroot/mspgcc
urlbase=ftp://ftp.gnu.org/pub/gnu/binutils
builddir=build-binutils

function die() {
    echo "$@" 1>&2
    exit 1
}

[ -f $scriptdir/$binutils-dollar.patch ] || die $scriptdir/$binutils-dollar.patch is missing
[ -d mspgcc-packaging ] || cvs -d $cvsroot co -d mspgcc-packaging -P packaging
[ -f $binutils.tar.bz2 ] || curl -O $urlbase/$binutils.tar.bz2

rm -rf $binutils
tar xjf $binutils.tar.bz2
patch -p1 -d $binutils < mspgcc-packaging/patches/$binutils-patch
patch -p1 -d $binutils < $scriptdir/$binutils-dollar.patch

rm -rf $builddir
mkdir -p $builddir
cd $builddir
../$binutils/configure --target=msp430 --prefix=$prefix --disable-nls
make -j32
# sudo make install
