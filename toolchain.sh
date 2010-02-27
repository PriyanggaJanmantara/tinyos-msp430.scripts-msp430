#!/bin/bash -u
# -*- mode: shell-script; mode: flyspell-prog; -*-

. $(dirname $0)/main.subr

PATH=$prefix/bin:$PATH

modules="binutils gcc msp430-libc gdb gdbproxy mspdebug"

if [[ $# -eq 0 ]]; then
    for module in $modules; do
	$scriptdir/$module.sh download build install
    done
elif [[ $1 == "cleanup" ]]; then
    for module in $modules; do
	$scriptdir/$module.sh cleanup
    done
fi

# Local Variables:
# indent-tabs-mode: nil
# End:
# vim: set et ts=4 sw=4:
