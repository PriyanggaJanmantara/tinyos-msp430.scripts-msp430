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
    msp430_prepare
    if [[ $release_mspgcc ]]; then
        [[ -f $binutils.tar.bz2 ]] \
            || fetch $url_binutils $binutils.tar.bz2 \
            || die "can not fetch binutils from $url_binutils"
    else
        [[ -d $binutils ]] \
            && { cd $binutils; git pull; cd $buildtop; } \
            || { git clone $repo_binutils $binutils \
            || die "can not clone binutils project from $repo_binutils repository"; }
    fi
    return 0
}

function prepare() {
    msp430_prepare
    if [[ $release_mspgcc ]]; then
        patch_binutils=$(msp430_patch_file binutils)
        binutils=$(msp430_gnu_version $patch_binutils)
        rm -rf $binutils
        tar xjf $binutils.tar.bz2
        patch -p1 -d $binutils < $patch_binutils
    fi
    return 0
}

function build() {
    msp430_prepare
    rm -rf $builddir
    mkdir $builddir
    cd $builddir
    ../$binutils/configure --target=$target --prefix=$prefix \
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
    msp430_prepare
    if [[ $release_mspgcc ]]; then
        rm -rf $binutils
    else
        cd $binutils
        git checkout .
    fi
    rm -rf $builddir
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
