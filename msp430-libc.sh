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
    [[ -d mspgcc ]] || mkdir mspgcc
    cd mspgcc
    [[ -d msp430-libc ]] \
        && { cd msp430-libc; cvs -q up; cd ..; } \
        || { cvs -q -d $repo_mspgcc co -P msp430-libc \
        || die "can not fetch cvs repository"; }
    cd ..
    [[ -d mspgcc4 ]] \
        && { cd mspgcc4; svn up; cd ..; } \
        || { svn co $repo_mspgcc4 mspgcc4 \
        || die "can not fetch mspgcc4 project from $repo_mspgcc4 repository"; }
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $builddir
    cp -R mspgcc/msp430-libc $builddir
    patch -p1 -d $builddir < mspgcc4/msp430-libc.patch \
        || die "apply mspgcc4/msp430-libc.patch failed"
    mkdir -p $builddir/src/msp1
    mkdir -p $builddir/src/msp2
    return 0
}

function build() {
    cd $builddir/src
    rm -f Makefile.new
    sed -e "s;/usr/local/msp430;$prefix;" Makefile > Makefile.new
    mv Makefile.new Makefile
    make -j$(num_cpus) \
        || die "make failed"
}

function install() {
    cd $builddir/src
    sudo make install

    cd $buildtop

    sudo rm -f $prefix/lib/libstdc.a
    sudo echo '!<arch>' > $prefix/lib/libstdc.a

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
