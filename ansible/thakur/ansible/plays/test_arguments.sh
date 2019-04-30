#!/bin/bash

# test.sh

echo "You provided the arguments: " "$@"
echo "You provided $# arguments"

if [[ $# -eq 0 ]] ; then
    echo 'some message'
    exit 0
fi

if [[ $# -eq 1 ]] ; then
    echo 'some message for 1 argument'
    exit 0
fi

echo "Arg 0: $0"
echo "Arg 1: $1"
echo "Arg 2: $2"
echo "Arg 3: $3"
echo "Arg 4: $4"
