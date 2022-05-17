#!/bin/sh

# Fuzzy find a file from $HOME, move to that file directory, and then opens it on $EDITOR.

# notes: keep in mind that if you want to cd automatically to the file you need to source the script.
# I will just recommend to create an alias/keybind.

FzfToFile() {
    File=$1

    # It would be a problem if we are in ./, but
    # calling this script in the same folder were the file is located is silly
    cd "${File%/*}"
    $EDITOR "$File"

    unset File
}

if [ "$1" = '-' ]; then
    if [ -n "$_GF_LAST_FILE_VISITED" ]; then
        FzfToFile "$_GF_LAST_FILE_VISITED"
    else
        echo "No previous file visited" 1>&2
    fi

    return 1
fi

BaseDir=$1

File=$(fd -tf -tl -H --exclude .git . "${BaseDir:-$HOME}" | fzf -i +m --black)
if [ -r "$File" ]; then
    export _GF_LAST_FILE_VISITED="$File"
    FzfToFile "$File"
fi
