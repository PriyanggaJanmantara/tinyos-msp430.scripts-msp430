#!/bin/bash -u

. $(dirname $0)/main.subr

function download() {
    cd $buildtop
    rm -rf $builddir
    if [[ -d ../$tinyos ]]; then
	cp -R ../$tinyos/tools/ $builddir
    elif [[ -d $tinyos ]]; then
	cd $tinyos; cvs -q up; cd ..;
	cp -R $tinyos/tools/ $builddir
    else
	cvs -q -d $repo_tinyos co -P $tinyos \
            || die "can not fetch from cvs repository"; \
	    cp -R $tinyos/tools/ $builddir
    fi
}

function prepare() {
    cd $buildtop
}

function build() { 
    cd $builddir
   ./Bootstrap \
	|| die "bootstrap failed"
    ./configure --prefix=$prefix --disable-nls \
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
