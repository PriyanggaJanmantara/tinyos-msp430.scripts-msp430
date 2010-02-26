#!/bin/sh -xu

scriptdir=$(dirname $0)
. $scriptdir/config.sh

builddir=build-tinyos-tools

[ -d $tinyos ] \
    && { cd $tinyos; cvs -q up; cd ..; } \
    || { cvs -q -d $repotinyos co -P $tinyos \
      || die "can not fetch from cvs repository"; }

rm -rf $builddir
cp -R $tinyos/tools $builddir
cd $builddir
./Bootstrap \
    || die "bootstrap failed"
./configure --prefix=$prefix --disable-nls \
    || die "configure failed"
make \
    || die "make failed"

# make install