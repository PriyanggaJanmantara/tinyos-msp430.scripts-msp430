#!/bin/sh -xu

scriptdir=$(dirname $0)
. $scriptdir/config.sh

gcc=gcc-3.2.3
gcccore=$(echo $gcc | sed 's/gcc-/gcc-core-/')

builddir=build-gcc

[ -f $scriptdir/$gcc-config_gcc.patch ] \
    || die $scriptdir/$gcc-config_gcc.patch missing
[ -d mspgcc-gcc ] \
    || cvs -d $repomspgcc co -d mspgcc-gcc -P gcc \
    || die "can not fetch from cvs repository"
[ -f $gcccore.tar.bz2 ] \
    || curl -O $urlgnu/gcc/$gcc/$gcccore.tar.bz2 \
    || die "can not fetch tarball"
[ -f gcc-core-3.3.6.tar.bz2 ] \
    || curl -O $urlgnu/gcc/gcc-3.3.6/gcc-core-3.3.6.tar.bz2 \
    || die "can not fetch tarball"

rm -rf $gcc
tar xjf $gcccore.tar.bz2
rm -rf gcc-3.3.6
tar xjf gcc-core-3.3.6.tar.bz2
tar cf - -C mspgcc-gcc/gcc-3.3 --exclude=CVS --exclude='THIS*' --exclude='*.patch' . | \
    tar xvf - -C $gcc
(cd gcc-3.3.6; tar cf - $(find . -name '*darwin*' -o -name config.gcc)) | \
    tar xvf - -C $gcc
patch -p1 -d $gcc < $scriptdir/$gcc-config_gcc.patch \
    || die "apply patch failed"

rm -rf $builddir
mkdir -p $builddir
cd $builddir
PATH=$prefix/bin:$PATH
../$gcc/configure --target=msp430 --prefix=$prefix --disable-nls \
    --with-as=$prefix/bin/msp430-as --with-ld=$prefix/bin/msp430-ld \
    || die "configure failed"
make \
    || die "make failed"
# sudo make install

repo=$prefix/repository/$gcc
echo rm $repo/lib/libeberty.a
echo ln -s $prefix/msp430/include $repo/msp430
echo ln -s $prefix/msp430/lib $repo/msp430
