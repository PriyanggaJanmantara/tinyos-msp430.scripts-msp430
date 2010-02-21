#!/bin/bash -u

. $(dirname $0)/main.subr

function download() {
    cd $buildtop
    rm -rf $builddir
    if [[ -d $tinyos ]]; then
	cd $tinyos; cvs -q up; cd ..;
    else
	cvs -q -d $repo_tinyos co -P $tinyos \
            || die "can not fetch from cvs repository";
    fi
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $builddir
    cp -R $tinyos $builddir \
	|| die "can not copy $tinyos"
    if [[ "$scriptdir/tinyos-tools-*.patch" ]]; then
	for p in $scriptdir/tinyos-tools-*.patch; do
	    patch -d $builddir -p1 < $p \
		|| die "patch $p failed"
	done
    fi
    return 0
}

function build() { 
    cd $builddir/tools
    ./Bootstrap \
	|| die "bootstrap failed"
    ./configure --prefix=$prefix --disable-nls \
	|| die "configure failed"
    make -j$(num_cpus) \
	|| die "make failed"
}

function install() {
    cd $builddir/tools
    sudo make install
}

function cleanup() {
    cd $buildtop
    rm -rf $builddir
}

main "$@"
