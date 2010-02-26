#!/bin/sh

scriptdir=$(dirname $0)
prefix=/stow
binutils=binutils-2.19.1
repourl=https://mspgcc4.svn.sourceforge.net/svnroot/mspgcc4
urlbase=ftp://ftp.gnu.org/pub/gnu/binutils
builddir=build-binutils
expr $(uname -r) : 10.0 > /dev/null && osx10=yes

function die() {
    echo "$@" 1>&2
    exit 1
}

[ -f $scriptdir/$binutils-dollar.patch ] || die $scriptdir/$binutils-dollar.patch is missing
[ -d mspgcc4 ] || svn co $repourl mspgcc4
[ -f $binutils.tar.bz2 ] || curl -O $urlbase/$binutils.tar.bz2

rm -rf $binutils
tar xjf $binutils.tar.bz2
patch -p1 -d $binutils < mspgcc4/$binutils.patch
patch -p1 -d $binutils < $scriptdir/$binutils-dollar.patch

rm -rf $builddir
mkdir -p $builddir
cd $builddir
[ -n "$osx10" ] && disable_werror=--disable-werror
../$binutils/configure --target=msp430 --prefix=$prefix --disable-nls $disable_werror
make -j32
# sudo make install
