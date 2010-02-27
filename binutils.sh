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
        || die "can not fetch from mspgcc4 repository"; }
    [[ -f $binutils.tar.bz2 ]] \
        || fetch $url_gnu/binutils/$binutils.tar.bz2
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $binutils
    tar xjf $binutils.tar.bz2

    patch -p1 -d $binutils < mspgcc4/$binutils.patch \
        || die "apply patch falied"

    if [[ "$scriptdir/$binutils-*.patch" ]]; then
        for p in $scriptdir/$binutils-*.patch; do
            patch -p1 -d $binutils < $p \
                || die "patch $p failed"
        done
    fi
    return 0
}

function build() {
    rm -rf $builddir
    mkdir $builddir
    cd $builddir

    disable_werror=
    is_osx_snow_leopard && disable_werror=--disable-werror
    ../$binutils/configure --target=$target --prefix=$prefix \
        --disable-nls $disable_werror \
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
    rm -rf $builddir $binutils
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
