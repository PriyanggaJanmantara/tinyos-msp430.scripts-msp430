#!/bin/bash -u

. $(dirname $0)/main.subr

PATH=$prefix/bin:$PATH

modules="binutils gcc msp430-libc gdb gdbproxy mspdebug"

for module in $modules; do
    $scriptdir/$module.sh download build install cleanup
done
