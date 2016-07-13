#!/bin/bash
#
# tryuntilsuccess.sh N cmd arg1 arg2 ...
# ======================================
# Executes a bash command 'cmd'. If it fails it is called again. N sets a limit on the number of attempts.
#
# https://github.com/gustafsson/tryuntilsuccess.sh

set -e

N=$1
cmd=$2

shift 2
while [ $# -gt 0 ]
do
  args="$args $1"
  shift
done

if ! [[ "$N" =~ ^[0-9]+$ ]] ; then
	echo Syntax $0 N cmd args
	echo N was not a number. Got '$N'
	false
fi

if [[ "$N" == "0" ]] ; then
	echo Syntax $0 N cmd args
	echo N bust be at least 1. Got '$N'
fi

if [ -z '$cmd' ] ; then
	echo Syntax $0 N cmd args
	echo cmd was empty
	false
fi

# Catch any errors during the first N-1 number of attempts 
for attempt in `seq 1 $(($N - 1))` ; do
	echo Attempt $attempt of $N: $cmd $args
	fail=
	$cmd $args || fail=1
	if [ -z $fail ] ; then
		echo Success on attempt number $attempt
		exit
	fi
done

# Run without catching error
echo Attempt $N of $N: $cmd $args
$cmd $args
