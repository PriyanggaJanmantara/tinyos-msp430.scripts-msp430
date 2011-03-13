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
    [[ -d mspgcc4 ]] \
        && { cd mspgcc4; git pull; cd ..; } \
        || { git clone $repo_mspgcc4 mspgcc4 \
        || die "can not clone mspgcc4 project from $repo_mspgcc4 repository"; }
    [[ -f $msp430libc.tar.bz2 ]] \
        || fetch $url_msp430libc $msp430libc.tar.bz2
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $builddir
    tar xjf $msp430libc.tar.bz2
    mv $msp430libc $builddir

    for p in $scriptdir/$msp430libc-fix_*.patch; do
        [[ -f $p ]] || continue
        patch -d $builddir -p1 < $p \
            || die "patch $p failed"
    done
    return 0
}

function build() {
    cd $builddir/src
    make -j$(num_cpus) PREFIX=$prefix \
        || die "make failed"
}

function install() {
    cd $builddir/src
    sudo make install PREFIX=$prefix

    cd $buildtop

    echo '!<arch>' > $builddir/0lib.tmp
    sudo mv $builddir/0lib.tmp $prefix/lib/libstdc++.a

    sudo rm -f $prefix/msp430/include/inttypes.h
    sudo ln -s $prefix/msp430/include/sys/inttypes.h $prefix/msp430/include/inttypes.h
}

function cleanup() {
    cd $buildtop
    rm -rf $builddir
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
