#!/bin/bash

########### GLOBALS ###########
declare destination
declare words
declare -a wordsArray
declare -a filesToCopy

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

report() {

    filename="report"
    i=1
    while [ -f "$destination/$filename.txt" ]
    do
        filename="report$i"
        echo "$i"
        ((i=i+1))
    done

    echo "$destination/$filename"
    touch "$destination/$filename.txt"
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
        echo "ERROR: \"$1\" is not an existing directory." 2> ~/log.txt # Hoe moet deze error gehandeld worden? Misschien uit function breaken op een of andere manier want "exit 1" sluit de hele console.
    fi
}

configureBB() {
    declare OPTARG
    declare arg
    declare OPTIND

    unset destination
    unset words

    while getopts ':d:b:' arg
    do
        case $arg in
        d)
            destination="$OPTARG"
            checkDir "$destination"
            # echo "$OPTARG"
            ;;

        b)
            words="$OPTARG"
            if [ ! -f "$words" ] # check of file bestaat
            then
                echo "ERROR: $words is not an existing file." 2> ~/log.txt # Hoe moet deze error gehandeld worden? Misschien uit function breaken op een of andere manier want "exit 1" sluit de hele console.
            fi
            # echo "$OPTARG"
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
        destination="./$directory"
        createArchive
    fi

    if [ -z "$words" ]
    then
        wordsArray=("bad")
        #touch defaultwords.txt
        #echo "bad" > defaultwords.txt
        #words="./defaultwords.txt"
    else
        # Maak een array van alles wat in de file $words staat
        mapfile -t wordsArray < "$words"
    fi

    echo "-d = $destination"
    echo "-b = ${wordsArray[*]}"
}


runBB() {
    unset filesToCopy
    declare -a uniqsArr

    for i in "${wordsArray[@]}" #grepping filenames
    do
        filesToCopy+=($(grep -r "$i" ./ | cut -f 1 -d ":"))
    done

    echo "filesToCopy array: "
    for i in "${filesToCopy[@]}"
    do
        echo $i
    done

    uniqsArr=($(echo "${filesToCopy[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')) #sorting array
    echo "unique array: "
    for i in "${uniqsArr[@]}"
    do

        echo $i
    done

    echo "filenames: "
    for i in "${uniqsArr[@]}"
    do
        filename="${i##*/}"
        dateofCreation=$(stat -c '%w' "$i" | cut -d ' ' -f1 )
        owner=$(stat -c '%U' "$i")
        newName="${owner}_${dateofCreation}_${filename}"

        j=1
        while [ -f "$destination/$newName" ]
        do
            newName="$newName$j"
            ((j=j+1))
        done

        echo "$newName"
    done
    report
}

# Nog te doen
# Moet het programma terminaten als de dir niet bestaat?
# createArchive als destination bestaat




