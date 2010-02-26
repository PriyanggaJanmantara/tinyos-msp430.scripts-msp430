#!/bin/bash -u

. $(dirname $0)/main.sh

modules="nesc binutils gcc msp430-libc tinyos-tools mspdebug gdb"

for module in $modules; do
    $scriptdir/$module.sh download prepare build install cleanup
done
