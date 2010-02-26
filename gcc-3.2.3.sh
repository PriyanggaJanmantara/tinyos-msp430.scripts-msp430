#!/bin/sh

scriptdir=$(dirname $0)
prefix=/stow
cvsroot=:pserver:anonymous@mspgcc.cvs.sourceforge.net:/cvsroot/mspgcc
urlbase=ftp://ftp.gnu.org/pub/gnu/gcc
builddir=build-gcc

function die() {
    echo "$@" 1>&2
    exit 1
}

[ -f $scriptdir/gcc-3.2.3-config_gcc.patch ] || die $scriptdir/gcc-3.2.3-config_gcc.patch missing
[ -d mspgcc-gcc ] || cvs -d $cvsroot co -d mspgcc-gcc -P gcc
[ -f gcc-core-3.2.3.tar.bz2 ] || curl -O $urlbase/gcc-3.2.3/gcc-core-3.2.3.tar.bz2
[ -f gcc-core-3.3.6.tar.bz2 ] || curl -O $urlbase/gcc-3.3.6/gcc-core-3.3.6.tar.bz2

rm -rf gcc-3.2.3
tar xjf gcc-core-3.2.3.tar.bz2
rm -rf gcc-3.3.6
tar xjf gcc-core-3.3.6.tar.bz2
tar cf - -C mspgcc-gcc/gcc-3.3 --exclude=CVS --exclude='THIS*' --exclude='*.patch' . | \
    tar xvf - -C gcc-3.2.3
(cd gcc-3.3.6; tar cf - $(find . -name '*darwin*' -o -name config.gcc)) | \
    tar xvf - -C gcc-3.2.3
patch -p1 -d gcc-3.2.3 < $scriptdir/gcc-3.2.3-config_gcc.patch

rm -rf $builddir
mkdir -p $builddir
cd $builddir
PATH=$prefix/bin:$PATH
../gcc-3.2.3/configure --target=msp430 --prefix=$prefix --disable-nls --with-as=$prefix/bin/msp430-as --with-ld=$prefix/bin/msp430-ld
make -j32
# sudo make install