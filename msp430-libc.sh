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
    if [[ $release_mspgcc == current ]]; then
        [[ -d $msp430libc ]] \
            && { do_cd $msp430libc; do_cmd git pull; do_cd $buildtop; } \
            || { do_cmd git clone $repo_msp430libc $msp430libc \
            || die "can not clone msp430-libc project from $repo_msp430libc repository"; }
        [[ -d $msp430mcu ]] \
            && { do_cd $msp430mcu; do_cmd git checkout .; do_cmd git pull; do_cd $buildtop; } \
            || { do_cmd git clone $repo_msp430mcu $msp430mcu \
            || die "can not clone msp430mcu project from $repo_msp430mcu repository"; }
    else
        fetch $url_msp430libc $msp430libc.tar.bz2
        fetch $url_msp430mcu $msp430mcu.tar.bz2
        mspgcc::download_patches $msp430libc
        mspgcc::download_patches $msp430mcu
    fi
    return 0
}

function prepare() {
    if [[ $release_mspgcc == current ]]; then
        :
    else
        do_cmd rm -rf $msp430libc
        do_cmd tar xjf $msp430libc.tar.bz2
        mspgcc::apply_patches $msp430libc $msp430libc
        do_cmd rm -rf $msp430mcu
        do_cmd tar xjf $msp430mcu.tar.bz2
        mspgcc::apply_patches $msp430mcu $msp430mcu
    fi

    for p in $scriptdir/msp430-libc-fix_*.patch; do
        [[ -f $p ]] || continue
        do_cmd "patch -d $msp430libc -p1 < $p" \
            || die "patch $p failed"
    done

    for p in $scriptdir/msp430mcu-fix_*.patch; do
        [[ -f $p ]] || continue
        do_cmd "patch -d $msp430mcu -p1 < $p" \
            || die "patch $p failed"
    done

    return 0
}

function build() {
    do_cd $msp430libc/src
    do_cmd rm -rf Build
    do_cmd make -j$(num_cpus) PREFIX=$prefix \
        || die "make failed"
}

function install() {
    do_cd $buildtop/$msp430libc/src
    do_cmd sudo make -j$(num_cpus) install PREFIX=$prefix
    do_cd $buildtop/$msp430mcu
    do_cmd sudo sh scripts/install.sh $prefix $buildtop/$msp430mcu
}

function cleanup() {
    if [[ $release_mspgcc == current ]]; then
        do_cd $buildtop/$msp430libc/src
        do_cmd rm -rf Build
        do_cmd git checkout .

        do_cd $buildtop/$msp430mcu
        do_cmd git checkout .
    else
        do_cd $buildtop
        do_cmd rm -rf $msp430libc $msp430mcu
    fi
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
