#!/bin/bash -u

. $(dirname $0)/main.subr

libusb=$(which libusb-legacy-config || which libusb-config) 
[[ -x $libusb ]] \
    || die "libusb is not installed"

function download() {
    cd $buildtop
    [[ -f $mspdebug.tar.gz ]] \
	|| fetch $url_mspdebug/$mspdebug.tar.gz
}

function prepare() {
    cd $buildtop
    rm -rf $builddir $mspdebug
    tar xzf $mspdebug.tar.gz
    mv $mspdebug $builddir

    if is_osx; then
	COMPAT_FLAGS="-D'usb_detach_kernel_driver_np(x,y)'=0"
	COMPAT_FLAGS+=" -DB460800=460800"
	COMPAT_FLAGS+=" -I/opt/local/include"
	if [ -f $scriptdir/$mspdebug-osx_*.patch ]; then
	    patch -d $builddir -p1 < $scriptdir/$mspdebug-osx_*.patch
	fi
    fi
}

function build() {   
    cd $builddir
    make -j$(num_cpus) \
	CFLAGS+="$COMPAT_FLAGS" CFLAGS+=$($libusb --cflags) CFLAGS+=$($libusb --libs)
}

function install() {
    cd $builddir
    sudo cp mspdebug $prefix/bin
}

function cleanup() {
    cd $buildtop
    rm -rf $builddir
}

main "$@"
