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
    if [[ $newlib == newlib-current ]]; then
        clone git $newlib_repo $newlib
        do_cd $newlib
        git checkout master
        do_cd $buildtop
    else
        fetch $newlib_url/$newlib.tar.gz
    fi
    return 0
}

function prepare() {
    [[ $newlib == newlib-current ]] && return
    do_cd $buildtop
    [[ -d $newlib ]] \
        || copy $newlib.tar.gz $buildtop/$newlib
    for p in $scriptsdir/newlib-fix_*.patch; do
        do_patch $newlib $p -p1
    done
    return 0
}

function build() {
    [[ -d $builddir ]] && do_cmd rm -rf $builddir
    do_cmd mkdir $builddir
    do_cd $builddir
    do_cmd ../$newlib/configure \
        --target=$buildtarget \
        --prefix=$prefix \
        --disable-newlib-supplied-syscalls \
        --enable-newlib-reent-small \
        --disable-newlib-fseek-optimization \
        --disable-newlib-wide-orient \
        --enable-newlib-nano-formatted-io \
        --disable-newlib-io-float \
        --enable-newlib-nano-malloc \
        --disable-newlib-unbuf-stream-opt \
        --enable-lite-exit \
        --enable-newlib-global-atexit \
        --disable-nls \
        || die "configure failed"
    do_cmd make -j$(num_cpus) \
        'CFLAGS_FOR_TARGET="-DPREFER_SIZE_OVER_SPEED -D__OPTIMIZE_SIZE__ -Os -fomit-frame-pointer"' \
        || die "make failed"
}

function install() {
    do_cd $builddir
    do_cmd sudo make -j$(num_cpus) install
}

function cleanup() {
    do_cd $buildtop
    do_cmd rm -rf $builddir
    [[ $newlib == newlib-current ]] || do_cmd rm -rf $newlib
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
