#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog -*-

. $(dirname $0)/main.subr

libusb=$(which libusb-legacy-config || which libusb-config) 
[[ -x $libusb ]] \
    || die "libusb is not installed"

function download() {
    cd $buildtop
    [[ -f $mspdebug.tar.gz ]] \
        || fetch $url_mspdebug/$mspdebug.tar.gz \
        || die "can not download $mspdebug.tar.gz from $url_mspdebug"
    return 0
}

function prepare() {
    cd $buildtop
    rm -rf $builddir $mspdebug
    tar xzf $mspdebug.tar.gz
    mv $mspdebug $builddir

    if [[ "$scriptdir/$mspdebug-fix_*.patch" ]]; then
        for p in $scriptdir/$mspdebug-fix_*.patch; do
            patch -d $builddir -p1 < $p \
                || die "patch $p failed"
        done
    fi
    if [[ "$scriptdir/$mspdebug-enhance_*.patch" ]]; then
        for p in $scriptdir/$mspdebug-enhance_*.patch; do
            patch -d $builddir -p1 < $p \
                || die "patch $p failed"
        done
    fi

    CFLAGS=
    LDFLAGS=
    if is_osx; then
        CFLAGS+=" -I/opt/local/include" # compatibility for libelf
        CFLAGS+=" $($libusb --cflags)"  # compatibility for libusb
        LDFLAGS+=" $($libusb --libs)"   # compatibility for libusb
        CFLAGS+=" -DB460800=460800"
        if [[ "$scriptdir/$mspdebug-osx_*.patch" ]]; then
            for p in $scriptdir/$mspdebug-osx_*.patch; do
                patch -d $builddir -p1 < $p \
                    || die "patch $p failed"
            done
        fi
    fi
    return 0
}

function build() {   
    cd $builddir
    make -j$(num_cpus) CFLAGS+="$CFLAGS" LDFLAGS+="$LDFLAGS"
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

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
