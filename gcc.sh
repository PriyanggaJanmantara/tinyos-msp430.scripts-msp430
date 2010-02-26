#!/bin/bash -u

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

    rm -rf $gcc
    tar xjf $gcccore.tar.bz2
    rm -rf $gcc/gmp
    tar xjf $gmp.tar.bz2 -C $gcc
    mv $gcc/$gmp $gcc/gmp
    rm -rf $gcc/mpfr
    tar xjf $mpfr.tar.bz2 -C $gcc
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
    ../$gcc/configure --target=msp430 --prefix=$prefix \
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
