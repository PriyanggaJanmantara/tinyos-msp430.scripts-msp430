#!/bin/bash -u

. $(dirname $0)/main.subr

PATH=$prefix/bin:$PATH

modules="binutils gcc msp430-libc gdb gdbproxy mspdebug nesc tinyos-tools"

for module in $modules; do
    $scriptdir/$module.sh download prepare build install cleanup
done
