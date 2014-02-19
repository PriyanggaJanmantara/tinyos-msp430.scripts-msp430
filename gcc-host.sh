#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-
#
# Copyright (c) 2014, Tadashi G Takaoka
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# - Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
# - Neither the name of Tadashi G. Takaoka nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#

source $(dirname $0)/main.subr

function download() {
    do_cd $buildtop
    if [[ $gcc = gcc-current ]]; then
        clone git $gcc_repo $gcc
        do_cd $gcc
        git checkout trunk
        do_cd $buildtop
    else
        fetch $gnu_url/gcc/$gcc/$gcc.tar.bz2
    fi
    fetch $gnu_url/gmp/$gmp.tar.bz2
    fetch $gnu_url/mpfr/$mpfr.tar.bz2
    fetch $gnu_url/mpc/$mpc.tar.gz
    return 0
}

function prepare() {
    do_cd $buildtop
    [[ $gcc == gcc-current || -d $gcc ]] \
        || copy $gcc.tar.bz2 $buildtop/$gcc

    [[ -d $gmp ]] \
        || copy $gmp.tar.bz2 $buildtop/$gmp
    symlink $buildtop/$gmp $gcc/gmp

    [[ -d $mpfr ]] \
        || copy $mpfr.tar.bz2 $buildtop/$mpfr
    symlink $buildtop/$mpfr $gcc/mpfr

    [[ -d $mpc ]] \
        || copy $mpc.tar.gz $buildtop/$mpc
    symlink $buildtop/$mpc $gcc/mpc

    return 0
}

function build() {
    [[ -d $builddir ]] && do_cmd rm -rf $builddir
    do_cmd mkdir -p $builddir
    do_cd $builddir
    do_cmd ../$gcc/configure \
        --target=$buildtarget \
        --prefix=$prefix \
        --enable-languages="c" \
        --with-newlib \
        --with-gnu-as \
        --with-gnu-ld \
        --with-system-zlib \
        --disable-libmudflap \
        --disable-libgomp \
        --disable-libssp \
        --disable-shared \
        --disable-nls \
        || die "configure failed"
    do_cmd make -j$(num_cpus) all-host \
        || die "make failed"
}

function install() {
    do_cd $builddir
    do_cmd sudo make -j$(num_cpus) install-host
}

function cleanup() {
    do_cd $buildtop
    do_cmd rm -rf $builddir
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
