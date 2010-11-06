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
        && { cd mspgcc4; git pull; cd ..; } \
        || { git clone $repo_mspgcc4 mspgcc4 \
        || die "can not clone mspgcc4 project from $repo_mspgcc4 repository"; }
    [[ -f $gdb.tar.bz2 ]] \
        || fetch $url_gnu/gdb/$gdb.tar.bz2 \
        || die "can not down load $gdb.tar.bz2 from $url_gnu"
    return 0
}

function prepare() {
    cd $buildtop
    tar xjf $gdb.tar.bz2
    { \
        tar cf - --exclude=.svn -C mspgcc4/ports/gdb-6-and-7 . \
        | tar xvf - -C $gdb;\
    } \
        || die "copy gdb-6-and-7 failed"
    if [ -f mspgcc4/$gdb.patch ]; then
        patch -d $gdb -p1 < mspgcc4/$gdb.patch \
            || die "apply $gdb.patch failed"
    fi
    return 0
}

function build() {
    rm -rf $builddir
    mkdir $builddir
    cd $builddir
    ../$gdb/configure --target=$target --prefix=$prefix \
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
    rm -rf $builddir $gdb
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
