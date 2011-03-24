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

. $(dirname $0)/main.subr

function download() {
    cd $buildtop
    [[ -d mspgcc ]] || mkdir mspgcc
    [[ -d mspgcc/gcc ]] \
        && { cd mspgcc/gcc; git pull; cd $buildtop; } \
        || { git clone $repo_gcc mspgcc/gcc \
        || die "can not clone gcc project from $repo_gcc repository"; }
    [[ -f $gmp.tar.bz2 ]] \
        || fetch $url_gmp $gmp.tar.bz2 
    [[ -f $mpfr.tar.bz2 ]] \
        || fetch $url_mpfr $mpfr.tar.bz2
    [[ -f $mpc.tar.gz ]] \
        || fetch $url_mpc $mpc.tar.gz
    return 0
}

function prepare() {
    cd $buildtop

    tar xjf $gmp.tar.bz2
    [[ -d mspgcc/gcc/gmp ]] && rm -f mspgcc/gcc/gmp
    ln -s $buildtop/$gmp mspgcc/gcc/gmp

    tar xjf $mpfr.tar.bz2
    [[ -d mspgcc/gcc/mpfr ]] && rm -f mspgcc/gcc/mpfr
    ln -s $buildtop/$mpfr mspgcc/gcc/mpfr

    tar xzf $mpc.tar.gz
    [[ -d mspgcc/gcc/mpc ]] && rm -f mspgcc/gcc/mpc
    ln -s $buildtop/$mpc mspgcc/gcc/mpc

    for p in $scriptdir/gcc-fix_*.patch; do
        [[ -f $p ]] || continue
        patch -d mspgcc/gcc -p1 < $p \
            || die "patch $p failed"
    done

    return 0
}

function build() {
    rm -rf $builddir
    mkdir $builddir
    cd $builddir
    ../mspgcc/gcc/configure --target=$target --prefix=$prefix \
        --mandir=$prefix/share/man --infodir=$prefix/share/info \
        --enable-languages="c,c++" --with-gnu-as --with-gnu-ld \
        --disable-nls \
        || die "configure failed"
    make -j$(num_cpus) \
        || die "make failed"
}

function install() {
    cd $builddir
    sudo make install
}

function cleanup() {
    cd $buildtop/mspgcc/gcc
    rm -f gmp mpfr mpc
    git checkout .
    cd $buildtop
    rm -rf $builddir $gmp $mpfr $mpc
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
