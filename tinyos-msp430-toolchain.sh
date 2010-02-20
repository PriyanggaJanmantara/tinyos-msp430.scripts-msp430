#!/bin/bash -u

. $(dirname $0)/main.subr

PATH=$prefix/bin:$PATH

$scriptdir/msp430-toolchain.sh

modules="nesc tinyos-tools"

for module in $modules; do
    $scriptdir/$module.sh download build install cleanup
done
