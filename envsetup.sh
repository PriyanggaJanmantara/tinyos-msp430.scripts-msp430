# script for profile.d for bash shells, adjusted for each users
# installation by substituting @prefix@ for the actual tinyos tree
# installation point.

. $HOME/.bash_library/clist.sh
. $HOME/.bash_library/path.sh

export TOSROOT=
export TOSDIR=
export MAKERULES=

TOSROOT=/opt/tinyos/tinyos-2.x
TOSDIR=$TOSROOT/tos
MAKERULES=$TOSROOT/support/make/Makerules
$(clist::contains $CLASSPATH $TOSROOT/support/sdk/java/tinyos.jar) \
	|| CLASSPATH=$(clist $TOSROOT/support/sdk/java/tinyos.jar $CLASSPATH)

export TOSROOT
export TOSDIR
export CLASSPATH
export MAKERULES

path::addpath /stow/bin
path::addpath /stow/sbin
path::addpath /stow/man MANPATH

alias dis430='msp430-objdump -d'
