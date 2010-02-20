#!/bin/bash -u

. $(dirname $0)/main.subr

function download() {
    cd $buildtop
    [[ -d $gdbproxy ]] \
	&& { cd $gdbproxy; cvs -q up; cd ..; } \
	|| { cvs -q -d $repo_gdbproxy co -d $gdbproxy gdbproxy/gdbproxy/gdbproxy \
	|| die "can not fetch gdbproxy project from $repo_gdbproxy repository"; }
}

function prepare() {
    cd $buildtop
    rm -rf $builddir
    cp -R $gdbproxy $builddir
    mv $builddir/target_skeleton.c $builddir/target_msp430.c
    if [[ -f $scriptdir/$gdbproxy-msp430.patch ]]; then
	patch -d $builddir -p1 < $scriptdir/$gdbproxy-msp430.patch
    fi
}

function build() {
    cd $builddir
    ./bootstrap
    ./configure --target=powerpc --prefix=$prefix --disable-nls \
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
