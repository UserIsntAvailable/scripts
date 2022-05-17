#!/bin/sh

# Go to a directory

# notes: keep in mind that if you want to see the effect of cd you need to source the file.

BaseDir=$1

Dir=$(fd -td -H --exclude .git . "${BaseDir:-$HOME}" | fzf -i +m --black)
if [ -d "$Dir" ]; then
    cd "$Dir"
fi
