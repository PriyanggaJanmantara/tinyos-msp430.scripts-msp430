#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-
#
# Copyright (c) 2010, Tadashi G Takaoka
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
source $(dirname $0)/mspgcc.subr

function download() {
    mspgcc::config
    if [[ $mspgcc_release == current ]]; then
        clone git $mspgcc_repo/gcc $gcc
    else
        fetch $gnu_url/gcc/$gcc/$gcc.tar.bz2
        mspgcc::download_patches msp430-$gcc
    fi
    fetch $gnu_url/gmp/$gmp.tar.bz2
    fetch $mpfr_url/$mpfr/$mpfr.tar.bz2
    fetch $mpc_url/$mpc.tar.gz
    return 0
}

function prepare() {
    mspgcc::config
    if [[ $mspgcc_release == current ]]; then
        :
    else
        copy $gcc.tar.bz2 $gcc
        mspgcc::gnu_patch gcc | do_cmd patch -p1 -d $gcc
        mspgcc::apply_patches msp430-$gcc $gcc
    fi

    copy $gmp.tar.bz2 $buildtop/$gmp
    symlink $buildtop/$gmp $gcc/gmp

    copy $mpfr.tar.bz2 $buildtop/$mpfr
    symlink $buildtop/$mpfr $gcc/mpfr

    copy $mpc.tar.gz $buildtop/$mpc
    symlink $buildtop/$mpc $gcc/mpc

    return 0
}

function build() {
    mspgcc::config
    [[ -d $builddir ]] && do_cmd rm -rf $builddir
    do_cmd mkdir -p $builddir
    do_cd $builddir
    do_cmd ../$gcc/configure --target=$buildtarget --prefix=$prefix \
        --mandir=$prefix/share/man --infodir=$prefix/share/info \
        --enable-languages="c,c++" --with-gnu-as --with-gnu-ld --with-system-zlib \
        --with-mpfr-include=../$gcc/mpfr/src --with-mpfr-lib=mpfr/src/.libs \
        --disable-nls \
        || die "configure failed"
    do_cmd make -j$(num_cpus) \
        || die "make failed"
}

function install() {
    do_cd $builddir
    do_cmd sudo make -j$(num_cpus) install
}

function cleanup() {
    mspgcc::config
    if [[ $mspgcc_release == current ]]; then
        do_cd $buildtop/$gcc
        do_cmd rm -f gmp mpfr mpc
        do_cmd git checkout .
    else
        do_cmd rm -rf $buildtop/$gcc
    fi
    do_cd $buildtop
    do_cmd rm -rf $builddir $gmp $mpfr $mpc
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
