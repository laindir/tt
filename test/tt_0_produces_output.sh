#/bin/sh

test -x "$1" && "$1" 2> /dev/null | grep -q .
