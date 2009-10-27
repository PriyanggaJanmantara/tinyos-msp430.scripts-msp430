# script for profile.d for bash shells, adjusted for each users
# installation by substituting @prefix@ for the actual tinyos tree
# installation point.

export TOSROOT=
export TOSDIR=
export MAKERULES=

TOSROOT="/opt/tinyos/tinyos-2.x"
TOSDIR="$TOSROOT/tos"
CLASSPATH=$CLASSPATH:$TOSROOT/support/sdk/java
MAKERULES="$TOSROOT/support/make/Makerules"

export TOSROOT
export TOSDIR
export CLASSPATH
export MAKERULES
