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
        clone git $mspgcc_repo/binutils $binutils
    else
        fetch $binutils_url $binutils.tar.bz2
        mspgcc::download_patches msp430-$binutils
    fi
    return 0
}

function prepare() {
    mspgcc::config
    if [[ $mspgcc_release == current ]]; then
        :
    elif [[ ! -d $binutils ]]; then
        copy $binutils.tar.bz2 $buildtop/$binutils
        mspgcc::gnu_patch binutils | do_cmd patch -p1 -d $binutils
        mspgcc::apply_patches msp430-$binutils $binutils
        if is_osx_mountain_lion || is_osx_maverics; then
            for p in $scriptsdir/${binutils}-clang_*.patch; do
                do_patch $binutils $p -p1
            done
        fi
    fi
    return 0
}

function build() {
    mspgcc::config
    [[ -d $builddir ]] && do_cmd rm -rf $builddir
    do_cmd mkdir -p $builddir
    do_cd $builddir
    local werror=
    if is_osx_mountain_lion || is_osx_maverics; then
        export CC="gcc -Wno-deprecated-declarations -Wno-empty-body -Wno-self-assign"
        werror=--disable-werror
        echo "==== using $CC for clang ===="
    fi
    do_cmd ../$binutils/configure --target=$buildtarget --prefix=$prefix \
        --disable-nls $werror \
        || die "configure failed"
    do_cmd make -j$(num_cpus) \
        || die "make failed"
}

function install() {
    mspgcc::config
    do_cd $builddir
    do_cmd sudo make -j$(num_cpus) install
}

function cleanup() {
    mspgcc::config
    if [[ $mspgcc_release == current ]]; then
        do_cd $binutils
        do_cmd git checkout .
    else
        do_cmd rm -rf $binutils
    fi
    do_cmd rm -rf $builddir
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
