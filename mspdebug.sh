#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog -*-
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

libusb=$(which libusb-legacy-config || which libusb-config) 
[[ -x $libusb ]] \
    || die "libusb is not installed"

function download() {
    do_cd $buildtop
    if [[ $release_mspdebug == current ]]; then
        [[ -d $mspdebug ]] \
            && { do_cd $mspdebug; do_cmd git pull; do_cd ..; } \
            || { do_cmd git clone $repo_mspdebug \
            || die "can not fetch mspdebug project from $repo_mspdebug"; }
    else
        fetch $url_mspdebug $mspdebug.tar.gz
    fi
    return 0
}

function prepare() {
    do_cd $buildtop
    do_cmd rm -rf $builddir
    if [[ $release_mspdebug == current ]]; then
        do_cmd rsync -arC $mspdebug/ $builddir/
    else
        do_cmd rm -rf $mspdebug
        do_cmd tar xzf $mspdebug.tar.gz
        do_cmd mv $mspdebug $builddir
    fi

    for p in $scriptdir/mspdebug-fix_*.patch; do
        [[ -f $p ]] || continue
        do_cmd "patch -d $builddir -p1 < $p" \
            || die "patch $p failed"
    done
    for p in $scriptdir/mspdebug-enhance_*.patch; do
        [[ -f $p ]] || continue
        do_cmd "patch -d $builddir -p1 < $p" \
            || die "patch $p failed"
    done

    if is_osx; then
        for p in $scriptdir/mspdebug-osx_*.patch; do
            [[ -f $p ]] || continue
            do_cmd "patch -d $builddir -p1 < $p" \
                || die "patch $p failed"
        done
    fi
    return 0
}

function build() {   
    do_cd $builddir
    do_cmd make -j$(num_cpus) PREFIX=$prefix
}

function install() {
    do_cd $builddir
    do_cmd sudo make -j$(num_cpus) PREFIX=$prefix install
}

function cleanup() {
    do_cd $buildtop
    do_cmd rm -rf $builddir
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
