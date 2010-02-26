#!/bin/bash

. $(dirname $0)/utils.sh

# install prefix
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
binutils=binutils-2.19.1
gcc=gcc-4.4.2
gmp=gmp-4.3.1
mpfr=mpfr-2.4.1
urlmpfr=http://www.mpfr.org
gdb=gdb-7.0

# libusb
repolibusb=git://git.libusb.org/libusb.git

# mspdebug
urlmspdebug=http://homepages.xnet.co.nz/~dlbeer
mspdebug=mspdebug-0.4
