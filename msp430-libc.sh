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
        clone git $mspgcc_repo/msp430-libc $msp430libc
        clone git $mspgcc_repo/msp430mcu $msp430mcu
    else
        fetch $msp430libc_url $msp430libc.tar.bz2
        fetch $msp430mcu_url $msp430mcu.tar.bz2
        mspgcc::download_patches $msp430libc
        mspgcc::download_patches $msp430mcu
    fi
    return 0
}

function prepare() {
    mspgcc::config
    if [[ $mspgcc_release == current ]]; then
        :
    else
        copy $msp430libc.tar.bz2 $buildtop/$msp430libc
        mspgcc::apply_patches $msp430libc $msp430libc
        copy $msp430mcu.tar.bz2 $buildtop/$msp430mcu
        mspgcc::apply_patches $msp430mcu $msp430mcu
    fi

    for p in $scriptsdir/{$msp430libc,msp430-libc}-fix_*.patch; do
        do_patch $msp430libc $p -p1
    done

    for p in $scriptsdir/{$msp430mcu,msp430mcu}-fix_*.patch; do
        do_patch $msp430mcu $p -p1
    done

    return 0
}

function build() {
    mspgcc::config
    do_cd $msp430libc/src
    do_cmd rm -rf Build
    do_cmd make -j$(num_cpus) PREFIX=$prefix \
        || die "make failed"
}

function install() {
    mspgcc::config
    do_cd $buildtop/$msp430libc/src
    do_cmd sudo make -j$(num_cpus) install PREFIX=$prefix
    do_cd $buildtop/$msp430mcu
    do_cmd sudo sh scripts/install.sh $prefix $buildtop/$msp430mcu
}

function cleanup() {
    mspgcc::config
    if [[ $mspgcc_release == current ]]; then
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
