#!/bin/sh -xu

cvsroot=:pserver:anonymous@tinyos.cvs.sourceforge.net:/cvsroot/tinyos

function die() {
    echo "$@" 1>&2
    exit 1
}

[ -d tinyos-2.x ] \
    || cvs -d $cvsroot co -P tinyos-2.x \
    || die "can not fetch from cvs repository"


