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

source $(dirname $0)/main.subr

function mspdebug::config() {
    do_cd $buildtop
    if [[ $mspdebug_release == current ]]; then
        mspdebug=mspdebug
    else
        mspdebug=$mspdebug_release
    fi
}

function download() {
    mspdebug::config
    if [[ $mspdebug_release == current ]]; then
        clone git $mspdebug_repo $mspdebug
    else
        local url=$mspdebug_url/$mspdebug.tar.gz/download
        fetch $url $mspdebug.tar.gz
    fi
    return 0
}

function prepare() {
    mspdebug::config
    local libusb=$(which libusb-config) 
    if [[ ! -x $libusb ]]; then
        if [[ $(which port) =~ port ]]; then
            die "Please install libusb-compat by port command"
        else
            die "libusb-compat is not installed"
        fi
    fi

    if [[ $mspdebug_release == current ]]; then
        copy $mspdebug $builddir
    else
        copy $mspdebug.tar.gz $builddir
    fi

    for p in $scriptsdir/mspdebug-fix_*.patch; do
        do_patch $builddir $p -p1
    done
    for p in $scriptsdir/mspdebug-enhance_*.patch; do
        do_patch $builddir $p -p1
    done

    if is_osx; then
        for p in $scriptsdir/mspdebug-osx_*.patch; do
            do_patch $builddir $p -p1
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
