#!/bin/bash -u

. $(dirname $0)/main.subr

function download() {
    cd $buildtop
    [[ -d mspgcc4 ]] \
	&& { cd mspgcc4; svn up; cd ..; } \
	|| { svn co $repo_mspgcc4 mspgcc4 \
	|| die "can not fetch mspgcc4 project from $repo_mspgcc4 repository"; }
    [[ -f $gdb.tar.bz2 ]] \
	|| fetch $url_gnu/gdb/$gdb.tar.bz2 \
	|| die "can not down load $gdb.tar.bz2 from $url_gnu"
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $gdb
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
    ../$gdb/configure --target=msp430 --prefix=$prefix --disable-nls \
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
