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

gcccore=$(echo $gcc | sed 's/gcc-/gcc-core-/')

function download() {
    cd $buildtop
    [[ -d mspgcc ]] || mkdir mspgcc
    cd mspgcc
    [[ -d gcc ]] \
        && { cd gcc; cvs -q up; cd ..; } \
        || { cvs -q -d $repo_mspgcc co -P gcc \
        || die "can not fetch gcc project from $repo_mspgcc repository"; }
    cd ..
    [[ -d mspgcc4 ]] \
        && { cd mspgcc4; git pull; cd ..; } \
        || { git clone $repo_mspgcc4 mspgcc4 \
        || die "can not clone mspgcc4 project from $repo_mspgcc4 repository"; }
    [[ -f $gcccore.tar.bz2 ]] \
        || fetch $url_gnu/gcc/$gcc/$gcccore.tar.bz2 \
        || die "can not download $gcccore.tar.bz2 from $url_gnu"
    [[ -f $gmp.tar.bz2 ]] \
        || fetch $url_gnu/gmp/$gmp.tar.bz2 \
        || die "can not download $gmp.tar.bz2 from $url_gnu"
    [[ -f $mpfr.tar.bz2 ]] \
        || fetch $url_mpfr/$mpfr/$mpfr.tar.bz2 \
        || die "can not download $mpfr.tar.bz2 from $url_mpfr"
    return 0
}

function prepare() {
    cd $buildtop
    { tar cf - --exclude=.git -C mspgcc4/ports gcc-4.x \
        | tar xvf - -C mspgcc/gcc; } \
        || die "copy gcc-4.x port failed"
    if [[ -f mspgcc4/msp$mspgccdir.patch ]]; then
        patch -d mspgcc/gcc/$mspgccdir -p1 < mspgcc4/msp$mspgccdir.patch \
            || die "apply msp$mspgccdir.patch failed"
    fi

    tar xjf $gcccore.tar.bz2
    tar xjf $gmp.tar.bz2 -C $gcc
    [[ -d $gcc/gmp ]] && rm -rf $gcc/gmp
    mv $gcc/$gmp $gcc/gmp
    tar xjf $mpfr.tar.bz2 -C $gcc
    [[ -d $gcc/mpfr ]] && rm -rf $gcc/mpfr
    mv $gcc/$mpfr $gcc/mpfr
    if [[ -f mspgcc4/$gcc.patch ]]; then
        patch -d $gcc -p1 < mspgcc4/$gcc.patch \
            || die "apply $gcc.patch failed"
    fi
    { tar cf - --exclude=CVS -C mspgcc/gcc/$mspgccdir . | tar xvf - -C $gcc; } \
        || die "copy $mspgccdir failed"

    for p in $scriptdir/$gcccore-fix_*.patch; do
        [[ -f $p ]] || continue
        patch -d $gcc -p1 < $p \
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
        --with-gnu-as --with-gnu-ld \
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
    cd $buildtop
    rm -rf $builddir $gcc
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
