#!/bin/bash -xu

scriptdir=$(dirname $0)
. $scriptdir/config.sh

builddir=build-msp430-libc

[ -d mspgcc ] || mkdir mspgcc
cd mspgcc
[ -d msp430-libc ] \
    && { cd msp430-libc; cvs -q up; cd ..; } \
    || { cvs -q -d $repomspgcc co -P msp430-libc \
      || die "can not fetch cvs repository"; }
cd ..
[ -d mspgcc4 ] \
    && { cd mspgcc4; svn up; cd ..; } \
    || { svn co $repomspgcc4 mspgcc4 \
      || die "can not fetch mspgcc4 project from $repomspgcc4 repository"; }

rm -rf $builddir
cp -R mspgcc/msp430-libc $builddir
patch -p1 -d $builddir < mspgcc4/msp430-libc.patch \
    || die "apply msp430-libc.patch failed"
mkdir $builddir/src/msp1
mkdir $builddir/src/msp2

cd $builddir/src
rm -f Makefile.new
sed -e "s;/usr/local/msp430;$prefix;" Makefile > Makefile.new
mv Makefile.new Makefile
make \
    || die "make failed"
# sudo make install
