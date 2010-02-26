#!/bin/bash

function die() {
    echo "$@" 1>&2
    exit 1
}

function is_osx() {
    [[ $(uname) = Darwin ]] && return 0 || return 1
}

function is_osx_snow_leopard() {
    [[ is_osx && $(uname -r) =~ "10.2" ]] && return 0 || return 1
}

function is_linux() {
    [[ $(uname) = Linux ]] && return 0 || return 1
}

function num_cpus() {
    is_osx && { hwprefs cpu_count; return; }
    is_linux && { grep ^processor /proc/cpuinfo | wc -l; return; }
    echo 1
}

fetch="-none-"
which wget >/dev/null && fetch="wget"
which curl >/dev/null && fetch="curl -O"
[[ $fetch = "-none-" ]] && die "missing wget or curl"
which cvs >/dev/null || die "missing cvs"
which svn >/dev/null || die "missing svn"
which git >/dev/null || die "missing git"
