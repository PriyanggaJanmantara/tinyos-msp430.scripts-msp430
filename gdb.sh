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
        [[ -d $gdb ]] \
            && { do_cd $gdb; do_cmd git checkout .; do_cmd git pull; do_cd $buildtop; } \
            || { do_cmd git clone $repo_gdb $gdb -b $branch_gdb \
            || die "can not clone gdb project from $repo_gdb repository"; }
    else
        fetch $url_gdb $gdb.tar.bz2
    fi
    return 0
}

function prepare() {
    if [[ $release_mspgcc == current ]]; then
        :
    else
        do_cmd rm -rf $gdb
        do_cmd tar xjf $gdb.tar.bz2
        mspgcc::gnu_patch gdb | do_cmd patch -p1 -d $gdb
    fi

    for p in $scriptdir/gdb-fix_*.patch; do
        [[ -f $p ]] || continue
        do_cmd "patch -d $gdb -p1 < $p" \
            || die "patch $p failed"
    done

    return 0
}

function build() {
    do_cmd rm -rf $builddir
    do_cmd mkdir $builddir
    do_cd $builddir
    do_cmd ../$gdb/configure --target=$target --prefix=$prefix \
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
    if [[ $release_mspgcc == current ]]; then
        do_cd $buildtop/$gdb
        do_cmd git checkout .
    else
        do_cmd rm -rf $gdb
    fi
    do_cmd rm -rf $builddir
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
