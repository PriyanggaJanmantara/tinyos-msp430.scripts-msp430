#!/bin/bash -xu

scriptdir=$(dirname $0)
. $scriptdir/config.sh

builddir=build-binutils

[[ -f $scriptdir/$binutils-dollar.patch ]] \
    || die $scriptdir/$binutils-dollar.patch is missing
[[ -d mspgcc4 ]] \
    && { cd mspgcc4; svn up; cd ..; } \
    || { svn co $repomspgcc4 mspgcc4 \
      || die "can not fetch from mspgcc4 repository"; }
[[ -f $binutils.tar.bz2 ]] \
    || $fetch $urlgnu/binutils/$binutils.tar.bz2 \
    || die "can not fetch tarball"

rm -rf $binutils
tar xjf $binutils.tar.bz2
patch -p1 -d $binutils < mspgcc4/$binutils.patch \
    || die "apply patch falied"
patch -p1 -d $binutils < $scriptdir/$binutils-dollar.patch \
    || die "apply patch failed"

rm -rf $builddir
mkdir -p $builddir
cd $builddir
is_osx10 && disable_werror=--disable-werror || disable_werror=""
../$binutils/configure \
    --target=msp430 \
    --prefix=$prefix \
    --disable-nls $disable_werror \
    || die "configure failed"
make \
    || die "make failed"
# sudo make install
