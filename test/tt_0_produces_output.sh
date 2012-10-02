#/bin/sh

if [ -x "$1" ]; then
	"$1" 2> /dev/null | grep -q .
else
	false;
fi
