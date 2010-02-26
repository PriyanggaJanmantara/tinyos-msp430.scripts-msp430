#!/bin/bash

prefix=/stow

# tinyos
repotinyos=:pserver:anonymous@tinyos.cvs.sourceforge.net:/cvsroot/tinyos
tinyos=tinyos-2.x

# nesc
urlnesc=http://softlayer.dl.sourceforge.net/project/nescc/nescc/v1.3.1
nesc=nesc-1.3.1

# mspgcc & mspgcc4
repomspgcc=:pserver:anonymous@mspgcc.cvs.sourceforge.net:/cvsroot/mspgcc
repomspgcc4=https://mspgcc4.svn.sourceforge.net/svnroot/mspgcc4
mspgccdir=gcc-4.x

# gnu
urlgnu=ftp://ftp.gnu.org/pub/gnu
# binutils
binutils=binutils-2.19.1
# gcc
gcc=gcc-4.4.2
gmp=gmp-4.3.1
# mpftr
mpfr=mpfr-2.4.1
urlmpfr=http://www.mpfr.org
# gdb
gdb=gdb-7.0

# libusb
repolibusb=git://git.libusb.org/libusb.git

# mspdebug
urlmspdebug=http://homepages.xnet.co.nz/~dlbeer

function die() {
    echo "$@" 1>&2
    exit 1
}

function is_osx() {
    [[ $(uname) = Darwin ]] && return 0 || return 1
}

function is_osx10() {
    [[ is_osx && $(uname -r) =~ "10.0" ]] && return 0 || return 1
}

function is_linux() {
    [[ $(uname) = Linux ]] && return 0 || return 1
}

fetch="-none-"
which wget >/dev/null && fetch="wget"
which curl >/dev/null && fetch="curl -O"
[[ $fetch = "-none-" ]] && die "missing wget or curl"
which cvs >/dev/null || die "missing cvs"
which svn >/dev/null || die "missing svn"
which git >/dev/null || die "missing git"
