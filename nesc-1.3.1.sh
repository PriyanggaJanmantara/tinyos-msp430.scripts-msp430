#!/bin/sh

prefix=/stow
urlbase=http://softlayer.dl.sourceforge.net/project/nescc/nescc/v1.3.1
builddir=nesc-1.3.1

[ -f nesc-1.3.1.tar.gz ] || curl -O $urlbase/nesc-1.3.1.tar.gz

rm -rf $builddir
tar xzf nesc-1.3.1.tar.gz

cd $builddir
./configure --prefix=$prefix --disable-nls
make -j32
# sudo make install
