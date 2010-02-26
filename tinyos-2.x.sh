#!/bin/sh -xu

prefix=/stow
repotinyos=:pserver:anonymous@tinyos.cvs.sourceforge.net:/cvsroot/tinyos

function die() {
    echo "$@" 1>&2
    exit 1
}

[ -d tinyos-2.x ] \
    || cvs -d $repotinyos co -P tinyos-2.x \
    || die "can not fetch from cvs repository"

cd tinyos-2.x/tools
./Bootstrap \
    || die "bootstrap failed"
./configure --prefix=$prefix --disable-nls \
    || die "configure failed"
make \
    || die "make failed"

# make install