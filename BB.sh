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

createArchive() {
    directory="archive"
    i=1
    while [ -d "$directory" ]
    do
        directory="archive$i"
        ((i=i+1))
    done
    mkdir $directory || log "Failed to make a Archive"
}

checkDir() { # Accepteerd 1 directory als argument
    if [ ! -d "$1" ]
    then
        # Dir bestaat niet, geef error naar stderr en doe in log.txt
        echo "ERROR: \"$1\" is not an existing directory." 2> ~/log.txt
    fi
}

configureBB() {
    declare OPTARG
    declare arg
    declare OPTIND
    declare destination
    declare words

    while getopts ':d:b:' arg
    do
        case $arg in
        d)
            destination="$OPTARG"
            echo "$OPTARG"
            ;;

        b)
            words="$OPTARG"
            checkDir "$words"
            echo "$OPTARG"
            ;;

        \?)
            echo "ERROR: -"$OPTARG" is not a valid option."
            ;;

        esac
    done


    if [ -z $destination ]
    then
        directory="archive"
        i=1
        while [ -d "$directory" ]
        do
            directory="archive$i"
            ((i=i+1))
        done
        createArchive
    fi

    if [ -z "$words" ]
    then
        touch defaultwords.txt
        echo "bad" > defaultwords.txt
        words="./defaultwords.txt"
    fi

    # Maak een array van alles wat in de file $words staat
    mapfile -t wordsArray < "$words"

    echo "-d = $destination"
    echo "-b = ${wordsArray[*]}"
}

# Nog te doen
# bad words filteren met regex
# Moet het programma terminaten als de dir niet bestaat?
# createArchive als destination bestaat

