#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog -*-

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
