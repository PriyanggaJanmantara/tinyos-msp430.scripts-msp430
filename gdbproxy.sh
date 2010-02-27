#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-
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

function download() {
    cd $buildtop
    [[ -d $gdbproxy ]] \
        && { cd $gdbproxy; cvs -q up; cd ..; } \
        || { cvs -q -d $repo_gdbproxy co -d $gdbproxy gdbproxy/gdbproxy/gdbproxy \
        || die "can not fetch gdbproxy project from $repo_gdbproxy repository"; }
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $builddir
    cp -R $gdbproxy $builddir
    mv $builddir/target_skeleton.c $builddir/target_msp430.c \
        || die "can not find target_skeleton.c in $builddir"
    if [[ -f $scriptdir/$gdbproxy-msp430.patch ]]; then
        patch -d $builddir -p1 < $scriptdir/$gdbproxy-msp430.patch \
            || die "patch $scriptdir/$gdbproxy-msp430.patch failed"
    fi
    return 0
}

function build() {
    cd $builddir
    ./bootstrap
    ./configure --target=$target --prefix=$prefix \
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
    cd $buildtop
    rm -rf $builddir
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
