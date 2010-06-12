#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog -*-
#
#  Copyright (C) 2010 Tadashi G. Takaoka
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

. $(dirname $0)/main.subr

libusb=$(which libusb-legacy-config || which libusb-config) 
[[ -x $libusb ]] \
    || die "libusb is not installed"

function download() {
    cd $buildtop
    [[ -d mspdebug ]] \
        && { cd mspdebug; git pull; cd ..; } \
        || { git clone $repo_mspdebug \
        || die "can not fetch mspdebug project from $repo_mspdebug"; }
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $builddir
    cp -rp mspdebug $builddir

    for p in $scriptdir/mspdebug-fix_*.patch; do
        [[ -f $p ]] || continue
        patch -d $builddir -p1 < $p \
            || die "patch $p failed"
    done
    for p in $scriptdir/mspdebug-enhance_*.patch; do
        [[ -f $p ]] || continue
        patch -d $builddir -p1 < $p \
            || die "patch $p failed"
    done

    CFLAGS=
    LDFLAGS=
    if is_osx; then
        CFLAGS+=" -I/opt/local/include" # compatibility for libelf
        CFLAGS+=" $($libusb --cflags)"  # compatibility for libusb
        LDFLAGS+=" $($libusb --libs)"   # compatibility for libusb
        for p in $scriptdir/mspdebug-osx_*.patch; do
            [[ -f $p ]] || continue
            patch -d $builddir -p1 < $p \
                || die "patch $p failed"
        done
    fi
    return 0
}

function build() {   
    cd $builddir
    make -j$(num_cpus) PREFIX=$prefix CFLAGS+="$CFLAGS" LDFLAGS+="$LDFLAGS"
}

function install() {
    cd $builddir
    sudo make PREFIX=$prefix install
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
