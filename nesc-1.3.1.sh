#!/bin/sh

scriptdir=$(dirname $0)
prefix=/stow
urlbase=http://softlayer.dl.sourceforge.net/project/nescc/nescc/v1.3.1
builddir=nesc-1.3.1
expr $(uname -r) : 10.0 > /dev/null && osx10=yes

[ -f nesc-1.3.1.tar.gz ] || curl -O $urlbase/nesc-1.3.1.tar.gz

rm -rf $builddir
tar xzf nesc-1.3.1.tar.gz
[ -n "$osx10" ] && \
    patch -d $builddir -p1 < $scriptdir/nesc-1.3.1-osx_10.patch

cd $builddir
./configure --prefix=$prefix --disable-nls
make -j32
# sudo make install
