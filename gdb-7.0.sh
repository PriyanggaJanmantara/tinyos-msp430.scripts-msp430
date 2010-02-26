#!/bin/sh -xu

scriptdir=$(dirname $0)
prefix=/stow
gdb=gdb-7.0
repomspgcc4=https://mspgcc4.svn.sourceforge.net/svnroot/mspgcc4
urlgnu=ftp://ftp.gnu.org/pub/gnu
builddir=build-gdb

function die() {
    echo "$@" 1>&2
    exit 1
}

[ -d mspgcc4 ] \
    || svn co $repomspgcc4 mspgcc4 \
    || die "can not fetch mspgcc4 project from $repomspgcc4 repository"
[ -f $gdb.tar.bz2 ] \
    || curl -O $urlgnu/gdb/$gdb.tar.bz2 \
    || die "can not fetch $gdb.tar.bz2 tar ball"

rm -rf $gdb
tar xjf $gdb.tar.bz2
{ tar cf - --exclude=.svn -C mspgcc4/ports/gdb-6-and-7 . | tar xvf - -C $gdb; } \
    || die "copy gdb-6-and-7 failed"
if [ -f mspgcc4/$gdb.patch ]; then
    patch -d $gdb -p1 < mspgcc4/$gdb.patch \
	|| die "apply $gdb.patch failed"
fi

rm -rf $builddir
mkdir $builddir
cd $builddir
PATH=$prefix/bin:$PATH
../$gdb/configure --target=msp430 --prefix=$prefix --disable-nls \
    || die "configure failed"
make \
    || die "make failed"
# sudo make install
