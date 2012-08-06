#!/bin/bash
# Copyright (c) 2011, Tadashi G Takaoka
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# - Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
# - Neither the name of Tadashi G. Takaoka nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#

# create sed commands to replace absolute symbols.
replace_abssymbol=($(
	msp430-objdump -t "$@" | \
	    awk '$2~/[lg]/ && $3=="*ABS*" && $NF!~/^\./ {print $1,$NF}' | \
	    sed -E -e 's/^000([0-9a-f]+) ([a-zA-Z0-9_.]+)/-e s;((mov|jmp|call|and|bis|bic).*)([#\&])0x\1;\\1\\3\2;/'
	))

# create sed commands to replace absolute labels.
replace_abslabel=($(
	msp430-objdump -t "$@" | \
	    awk '$2~/[lg]/ && $4~/.text|.data|.bss/ && $NF!~/^\./ {print $1,$NF}' | \
	    sed -E -e 's/^000([0-9a-f]+) ([a-zA-Z0-9_.]+)/-e s;([#\&]?)0x\1;\\1\2;/'
	))

# create sed commands to replace weak symbols.
replace_weaksymbol=($(
	msp430-objdump -t "$@" | \
	    awk '$2~/[wg]/ && $3==".text" && $NF!~/^\./ {print $1,$NF}' | \
	    sed -E -e 's/^000([0-9a-f]+) ([a-zA-Z0-9_.]+)/-e s;([#\&]?)0x\1;\\1\2;/'
	))

# create sed commands to mark relative jumps operand to its absolute value surrounded by '@'.
mark_reljmp=($(
	msp430-objdump -d --no-show-raw-insn "$@" | \
	    egrep 'abs 0x[0-9a-f]+' | \
	    sed -E -e 's/([0-9a-f]+:).+\$([+-])([0-9]+).*;.*abs 0x([0-9a-f]+)/-e s;(\1.*)\\$\\\2\3;\\1@\4@;/'
	))

# create sed commands to replace relative jumps target address to generated labels.
replace_rellabel=($(
	msp430-objdump -d --no-show-raw-insn "$@" | \
	    egrep 'abs 0x[0-9a-f]+' | \
	    sed -E -e 's/.*;.*abs 0x([0-9a-f]+)/\1/' | \
	    sort -u | awk '{print NR"@"$1}' | \
	    sed -E -e 's/([0-9]+)@([0-9a-f]+)/-e s;^.*\2:;_\1:;/'
	))

# create sed commands to replace relative jumps operand to corresponding generated labels.
replace_reljmp=($(
	msp430-objdump -d --no-show-raw-insn "$@" | \
	    egrep 'abs 0x[0-9a-f]+' | \
	    sed -E -e 's/^.*;.*abs 0x([0-9a-f]+)/\1/' | \
	    sort -u | awk '{print NR"@"$1}' | \
	    sed -E -e 's/([0-9]+)@([0-9a-f]+)/-e s;@\2@;_\1;/'
	))

case "$*" in
*--no-show-raw-insn*)
  format_address="-e s/^[^_]+[0-9a-f]+://"
  ;;
*)
  format_address="-e s/^(_[0-9]+:)/\1     /"
  ;;
esac

# replace absolute labels
# delete unnecessary address
# delete constant generator comments
# replace register name r1 and r2 to sp and sr respectively
# delete empty comments
msp430-objdump -d "$@" | \
    sed -E \
        "${mark_reljmp[@]}" \
        "${replace_rellabel[@]}" \
        "${replace_reljmp[@]}" \
        "${replace_abssymbol[@]}" \
        "${replace_abslabel[@]}" \
        "${replace_weaksymbol[@]}" \
        -e 's/^([0-9a-f]{8}) <([a-zA-Z0-9_.]+)>:/\2:/' \
        "${format_address}" \
        -e 's/( *;)abs 0x[0-9a-f]+/\1/' \
        -e 's/r[23] As==[01][01],?//' \
        -e 's/([^a-zA-Z0-9_.])r1([^a-zA-Z0-9.])/\1sp\2/g' \
        -e 's/([^a-zA-Z0-9_.])r2([^a-zA-Z0-9.])/\1sr\2/g' \
        -e 's/ *; *$//'


