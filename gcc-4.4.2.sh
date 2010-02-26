#!/bin/sh -xu

scriptdir=$(dirname $0)
. $scriptdir/config.sh

gcccore=$(echo $gcc | sed 's/gcc-/gcc-core-/')

builddir=build-gcc

[ -d mspgcc ] || mkdir mspgcc
cd mspgcc
[ -d ngcc ] \
    || cvs -q -d $repomspgcc co -P gcc \
    || die "can not fetch gcc project from $repomspgcc repository"
cd ..
[ -d mspgcc4 ] \
    || svn co $repomspgcc4 mspgcc4 \
    || die "can not fetch mspgcc4 project from $repomspgcc4 repository"
[ -f $gcccore.tar.bz2 ] \
    || curl -O $urlgnu/gcc/$gcc/$gcccore.tar.bz2 \
    || die "can not fetch $gcccore.tar.bz2 tar ball"
[ -f $gmp.tar.bz2 ] \
    || curl -O $urlgnu/gmp/$gmp.tar.bz2 \
    || die "can not fetch $gmp.tar.bz2 tar ball"
[ -f $mpfr.tar.bz2 ] \
    || curl -O $urlmpfr/$mpfr/$mpfr.tar.bz2 \
    || die "can not fetch $mpfr.tar.bz2 tar ball"

{ tar cf - --exclude=.svn -C mspgcc4/ports gcc-4.x | tar xvf - -C mspgcc/gcc; } \
    || die "copy gcc-4.x port failed"
if [ -f mspgcc4/msp$mspgccdir.patch ]; then
    patch -d mspgcc/gcc/$mspgccdir -p1 < mspgcc4/msp$mspgccdir.patch \
	|| die "apply msp$mspgccdir.patch failed"
fi

rm -rf $gcc
tar xjf $gcccore.tar.bz2
rm -rf $gcc/gmp
tar xjf $gmp.tar.bz2 -C $gcc
mv $gcc/$gmp $gcc/gmp
rm -rf $gcc/mpfr
tar xjf $mpfr.tar.bz2 -C $gcc
mv $gcc/$mpfr $gcc/mpfr
if [ -f mspgcc4/$gcc.patch ]; then
    patch -d $gcc -p1 < mspgcc4/$gcc.patch \
	|| die "apply $gcc.patch failed"
fi
{ tar cf - --exclude=CVS -C mspgcc/gcc/$mspgccdir . | tar xvf - -C $gcc; } \
    || die "copy $mspgccdir failed"

rm -rf $builddir
mkdir $builddir
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
