#!/bin/bash

function die() {
    echo "$@" 1>&2
    exit 1
}

function is_osx() {
    [[ $(uname) = Darwin ]] && return 0 || return 1
}

function is_osx10() {
    [[ is_osx && $(uname -r) =~ "10.0" ]] && return 0 || return 1
}

function is_linux() {
    [[ $(uname) = Linux ]] && return 0 || return 1
}

fetch="-none-"
which wget >/dev/null && fetch="wget"
which curl >/dev/null && fetch="curl -O"
[[ $fetch = "-none-" ]] && die "missing wget or curl"
which cvs >/dev/null || die "missing cvs"
which svn >/dev/null || die "missing svn"
which git >/dev/null || die "missing git"
