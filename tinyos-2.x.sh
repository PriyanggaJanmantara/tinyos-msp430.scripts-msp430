#!/bin/sh

cvsroot=:pserver:anonymous@tinyos.cvs.sourceforge.net:/cvsroot/tinyos

[ -d tinyos-2.x ] || \
    cvs -d $cvsroot co -P tinyos-2.x


