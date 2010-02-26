#!/bin/bash -u

. $(dirname $0 )/main.subr

function download() {
    cd $buildtop
    [[ -f $nesc.tar.gz ]] \
	|| fetch $url_nesc/$nesc.tar.gz
}

function prepare() {
    cd $buildtop
    rm -rf $builddir
    tar xzf $nesc.tar.gz
    mv $nesc $builddir
    is_osx_snow_leopard \
	&& { patch -d $builddir -p1 < $scriptdir/$nesc-osx_snow_leopard.patch \
	|| die "apply patch failed"; }
}

function build() {
    cd $builddir
    ./configure --prefix=$prefix --disable-nls \
	|| die "configure failed"
    make -j$(num_cpus) \
	|| die "make filed"
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
