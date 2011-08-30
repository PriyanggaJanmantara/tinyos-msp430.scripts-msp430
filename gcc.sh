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
    if [[ $release_mspgcc == current ]]; then
        [[ -d $gcc ]] \
            && { cd $gcc; git checkout .; git pull; cd $buildtop; } \
            || { git clone $repo_gcc $gcc \
            || die "can not clone gcc project from $repo_gcc repository"; }
    else
        fetch $url_gcc $gcc.tar.bz2
        mspgcc::download_patches msp430-$gcc
    fi
    fetch $url_gmp $gmp.tar.bz2
    fetch $url_mpfr $mpfr.tar.bz2
    fetch $url_mpc $mpc.tar.gz
    return 0
}

function prepare() {
    if [[ $release_mspgcc == current ]]; then
        :
    else
        rm -rf $gcc
        tar xjf $gcc.tar.bz2
        mspgcc::gnu_patch gcc | patch -p1 -d $gcc
        mspgcc::apply_patches msp430-$gcc $gcc
    fi

    tar xjf $gmp.tar.bz2
    [[ -d $gcc/gmp ]] && rm -f $gcc/gmp
    ln -s $buildtop/$gmp $gcc/gmp

    tar xjf $mpfr.tar.bz2
    [[ -d $gcc/mpfr ]] && rm -f $gcc/mpfr
    ln -s $buildtop/$mpfr $gcc/mpfr

    tar xzf $mpc.tar.gz
    [[ -d $gcc/mpc ]] && rm -f $gcc/mpc
    ln -s $buildtop/$mpc $gcc/mpc

    for p in $scriptdir/gcc-fix_*.patch; do
        [[ -f $p ]] || continue
        cat $p | patch -d $gcc -p1 \
            || die "patch $p failed"
    done
    return 0
}

function build() {
    rm -rf $builddir
    mkdir $builddir
    cd $builddir
    ../$gcc/configure --target=$target --prefix=$prefix \
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
    if [[ $release_mspgcc == current ]]; then
        cd $buildtop/$gcc
        rm -f gmp mpfr mpc
        git checkout .
    else
        rm -rf $buildtop/$gcc
    fi
    cd $buildtop
    rm -rf $builddir $gmp $mpfr $mpc
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
