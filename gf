#!/bin/bash

# Fuzzy find a file from $HOME, move to that file directory, and then opens it
# on $EDITOR.

# Notes:
# Keep in mind that if you want to cd automatically to the file you need to
# source the script. I will just recommend to create an alias/keybind.
#
# I'm using `return`s, instead of `exit`s because this script needs to handle
# the case where it is `source`d instead of being run normally.

# Dependecies:
# fd
# fzf

# TODO: Save value of $_GF_LAST_FILE_VISITED on a temp file.

# -------------------------------- Functions -------------------------------- #

Usage()
{
    while read; do
        printf "%s\n" "$REPLY"
    done <<- EOF
        Usage: gf [BASEDIR]

          -h, --help                   - Display this help information.

        If called without arguments, BASEDIR will be the user's 'HOME'.
        The use of '-' to is similar to 'cd -', but also opens the last file.
	EOF
}

UnsetVars()
{
    unset File
}

Err()
{
    printf "Err: %s\n" "$2" 1>&2
    if (($1 > 0)); then
        UnsetVars
        return $1
    fi
}

FzfToFile()
{
    cd "${1%/*}" || return $(Err 1 "Wasn't possible to cd into '${1%/*}'.")
    $EDITOR "${1##*/}"
}

# ----------------------------- Input Processing ----------------------------- #

(($# > 1)) && return $(Err 1 "Too many arguments.")

case "$1" in
    --help | -h)
        Usage
        return 0
        ;;
    -)
        if [[ -n "$_GF_LAST_FILE_VISITED" ]]; then
            FzfToFile "$_GF_LAST_FILE_VISITED" && return 0 || return 1
        else
            return $(Err 1 "No previous file visited.")
        fi
        ;;
esac

File=$(fd -tf -tl -H --exclude .git . "${1:-$HOME}" | fzf -i +m --black)

[[ -r "$File" ]] || return $(Err 1 "File '$File' is not readable.")

# ----------------------------------- Main ----------------------------------- #

export _GF_LAST_FILE_VISITED="$File"
FzfToFile "$File" || return 1

UnsetVars
