#!/bin/sh -xu

scriptdir=$(dirname $0)
. $scriptdir/config.sh

builddir=build-nesc

[ -f $nesc.tar.gz ] \
    || curl -O $urlnesc/$nesc.tar.gz \
    || die "can not fetch tarball"

rm -rf $builddir
tar xzf $nesc.tar.gz
mv $nesc $builddir
is_osx10 \
    && { patch -d $builddir -p1 < $scriptdir/$nesc-osx_10.patch \
      || die "apply patch failed"; }

cd $builddir
./configure --prefix=$prefix --disable-nls \
    || die "configure failed"
make \
    || die "make filed"
# sudo make install
