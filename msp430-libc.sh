#!/bin/bash -u

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
}

function cleanup() {
    cd $buildtop
    rm -rf $builddir
}

main "$@"

