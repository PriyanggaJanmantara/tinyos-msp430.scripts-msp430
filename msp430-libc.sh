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
    [[ -d mspgcc4 ]] \
        && { cd mspgcc4; svn up; cd ..; } \
        || { svn co $repo_mspgcc4 mspgcc4 \
        || die "can not fetch mspgcc4 project from $repo_mspgcc4 repository"; }
    [[ -f $msp430libc.tar.bz2 ]] \
        || fetch $url_msp430libc/$msp430libc.tar.bz2
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $builddir
    tar xjf $msp430libc.tar.bz2

    return 0
}

function build() {
    rm -rf $builddir
    mv $msp430libc $builddir
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
