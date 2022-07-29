#!/bin/bash

log() {
error="there was an error in the execution, for more details check log.txt"

if [ -f ~/log.txt ]
then
    echo "$1" >> ~/log.txt
    echo $error
else
    touch ~/log.txt
    echo "$1" >> ~/log.txt
    echo $error
fi
}

configureBB() {

while getopts 'd:p:' arg
do
    case $arg in
    d)
        destination="$OPTARG"
        echo "$OPTARG";;
    p)
        words="$OPTARG"
        echo "$OPTARG";;
    *)
        log "invalid argument was passed to configureBB";;
    esac
done

if [ $destination == "" ]
then
    echo "yo"
fi
}

