#!/bin/bash

# Fuzzy find a file from $HOME, move to that file directory, and then opens it
# on $EDITOR.

# notes:
# Keep in mind that if you want to cd automatically to the file you need to
# source the script. I will just recommend to create an alias/keybind.
# 
# I'm using `return`s, instead of `exit`s because this script needs to handle
# the case where the script is `source`d instead of being run normaly.

# TODO: Save value of $_GF_LAST_FILE_VISITED on a tmp file.

Err()
{
    printf "Err: %s\n" $2 1>&2
    (( $1 > 0 )) && return $1
}

FzfToFile()
{
    cd "${1%/*}"
    $EDITOR "${1##*/}"

    return 0
}

if [ "$1" = '-' ]; then
    if [ -n "$_GF_LAST_FILE_VISITED" ]; then
        return $(FzfToFile "$_GF_LAST_FILE_VISITED")
    else
        return $(Err 1 "No previous file visited.")
    fi
fi

File=$(fd -tf -tl -H --exclude .git . "${1:-$HOME}" | fzf -i +m --black)
if [ -r "$File" ]; then
    export _GF_LAST_FILE_VISITED="$File"
    FzfToFile "$File"
fi

unset BaseDir
unset File
