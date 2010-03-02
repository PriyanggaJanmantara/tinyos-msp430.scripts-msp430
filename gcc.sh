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

gcccore=$(echo $gcc | sed 's/gcc-/gcc-core-/')

function download() {
    cd $buildtop
    [[ -d mspgcc ]] || mkdir mspgcc
    cd mspgcc
    [[ -d gcc ]] \
        && { cd gcc; cvs -q up; cd ..; } \
        || { cvs -q -d $repo_mspgcc co -P gcc \
        || die "can not fetch gcc project from $repo_mspgcc repository"; }
    cd ..
    [[ -d mspgcc4 ]] \
        && { cd mspgcc4; svn up; cd ..; } \
        || { svn co $repo_mspgcc4 mspgcc4 \
        || die "can not fetch mspgcc4 project from $repo_mspgcc4 repository"; }
    [[ -f $gcccore.tar.bz2 ]] \
        || fetch $url_gnu/gcc/$gcc/$gcccore.tar.bz2 \
        || die "can not download $gcccore.tar.bz2 from $url_gnu"
    [[ -f $gmp.tar.bz2 ]] \
        || fetch $url_gnu/gmp/$gmp.tar.bz2 \
        || die "can not download $gmp.tar.bz2 from $url_gnu"
    [[ -f $mpfr.tar.bz2 ]] \
        || fetch $url_mpfr/$mpfr/$mpfr.tar.bz2 \
        || die "can not download $mpfr.tar.bz2 from $url_mpfr"
    return 0
}

function prepare() {
    cd $buildtop
    { tar cf - --exclude=.svn -C mspgcc4/ports gcc-4.x \
        | tar xvf - -C mspgcc/gcc; } \
        || die "copy gcc-4.x port failed"
    if [[ -f mspgcc4/msp$mspgccdir.patch ]]; then
        patch -d mspgcc/gcc/$mspgccdir -p1 < mspgcc4/msp$mspgccdir.patch \
            || die "apply msp$mspgccdir.patch failed"
    fi

    tar xjf $gcccore.tar.bz2
    tar xjf $gmp.tar.bz2 -C $gcc
    [[ -d $gcc/gmp ]] && rm -rf $gcc/gmp
    mv $gcc/$gmp $gcc/gmp
    tar xjf $mpfr.tar.bz2 -C $gcc
    [[ -d $gcc/mpfr ]] && rm -rf $gcc/mpfr
    mv $gcc/$mpfr $gcc/mpfr
    if [[ -f mspgcc4/$gcc.patch ]]; then
        patch -d $gcc -p1 < mspgcc4/$gcc.patch \
            || die "apply $gcc.patch failed"
    fi
    { tar cf - --exclude=CVS -C mspgcc/gcc/$mspgccdir . | tar xvf - -C $gcc; } \
        || die "copy $mspgccdir failed"
    return 0
}

function build() {
    rm -rf $builddir
    mkdir $builddir
    cd $builddir
    ../$gcc/configure --target=$target --prefix=$prefix \
        --mandir=$prefix/share/man --infodir=$prefix/share/info \
        --with-gnu-as --with-gnu-ld \
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
    rm -rf $builddir $gcc
}

main "$@"

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
