#!/bin/bash -xu

scriptdir=$(dirname $0)
. $scriptdir/config.sh

builddir=build-tinyos-tools

rm -rf $builddir
if [[ -d $tinyos ]]; then
    cd $tinyos; cvs -q up; cd ..;
    cp -R $tinyos/tools $builddir
elif [[ -d ../$tinyos ]]; then
    cp -R ../$tinyos/tools $builddir
else
    cvs -q -d $repotinyos co -P $tinyos \
        || die "can not fetch from cvs repository"; \
	cp -R $tinyos/tools $builddir
fi

cd $builddir
./Bootstrap \
    || die "bootstrap failed"
./configure --prefix=$prefix --disable-nls \
    || die "configure failed"
make -j$(num_cpus) \
    || die "make failed"

# make install
