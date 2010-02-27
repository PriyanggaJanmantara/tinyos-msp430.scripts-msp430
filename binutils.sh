#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog -*-

. $(dirname $0)/main.subr

function download() {
    cd $buildtop
    [[ -f $scriptdir/$binutils-dollar.patch ]] \
        || die $scriptdir/$binutils-dollar.patch is missing
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
    patch -p1 -d $binutils < $scriptdir/$binutils-dollar.patch \
        || die "apply patch failed"
    return 0
}

function build() {
    rm -rf $builddir
    mkdir $builddir
    cd $builddir
    is_osx_snow_leopard && disable_werror=--disable-werror || disable_werror=""
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
