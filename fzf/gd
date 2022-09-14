#!/bin/bash

# `cd` to a directory.

# Notes:
# Keep in mind that if you want to see the effect of cd you need to
# source the file.

# Dependecies:
# fd
# fzf

# TODO: Add flag to print full path of the directory when using -p.

# -------------------------------- Functions -------------------------------- #

Usage()
{
    while read; do
        printf "%s\n" "$REPLY"
    done <<- EOF
        Usage: gd [OPTS] [BASEDIR]

          -h, --help    - Display this help information.
          -p, --print   - Print the selected directory instead of 'cd'ing into it.

        If called without arguments, BASEDIR will be the user's 'HOME'.
	EOF
}

UnsetVars()
{
    unset Command
    unset BaseDir
}

Err()
{
    printf "Err: %s\n" "$2" 1>&2
    if (($1 > 0)); then
        UnsetVars
        return $1
    fi
}

# ----------------------------- Input Processing ----------------------------- #

(($# > 2)) && return $(Err 1 "Too many arguments.")

Command="cd"

case "$1" in
    --help | -h)
        Usage
        return 0
        ;;
    --print | -p)
        Command="echo"
        shift
        ;;
    -*) return $(Err 1 "Incorrect option(s) specified.") ;;
esac

BaseDir="${1:-$HOME}"

[[ -d "$BaseDir" ]] || return $(Err 1 "Directory '$BaseDir' doesn't exists.")

# ----------------------------------- Main ----------------------------------- #

$Command "$(fd -td -H --exclude .git . "$BaseDir" | fzf -i +m --black)"

UnsetVars
