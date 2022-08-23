#!/bin/bash

########### GLOBALS ###########
declare destination
declare words
declare -a wordsArray
declare -a filesToCopy

errorsOccured=0

log() {
    error="there was an error in the execution, for more details check log.txt"

    errorsOccured=1

    if [ ! -f ~/log.txt ]
    then
        touch ~/log.txt
    fi

    echo "$1" >> ~/log.txt
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

    log # Maakt een log file als die niet bestaat

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

    errorsOccured=0
}


runBB() {
    unset filesToCopy
    declare -a uniqsArr

    for i in "${wordsArray[@]}" #grepping filenames
    do
        filesToCopy+=($(grep -r --exclude="$words" "$i" ./ | cut -f 1 -d ":"))
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


    reportname="report"
    i=1
    while [ -f "$destination/$reportname.txt" ]
    do
        reportname="report$i"
        echo "$i"
        ((i=i+1))
    done

    echo "$destination/$reportname"
    touch "$destination/$reportname.txt"

    currentDate=`date +"%Y-%m-%d %T"`      ### reporting
    wd=`pwd`
    destAbsolute=`readlink -f $destination`
    badAbsolute=`readlink -f $words`
    echo "Report generated on: $currentDate" >> "$destination/$reportname.txt"
    echo "Original directory: $wd" >> "$destination/$reportname.txt"
    echo "Destination path: $destAbsolute" >> "$destination/$reportname.txt"
    echo "List with bad words: $badAbsolute" >> "$destination/$reportname.txt"
    echo "" >> "$destination/$reportname.txt"
    echo "" >> "$destination/$reportname.txt"
    echo "configureBB parameters: " >> "$destination/$reportname.txt"
    echo "  -d = $destination"  >> "$destination/$reportname.txt"
    echo "  -b = ${wordsArray[*]}" >> "$destination/$reportname.txt"
    echo "" >> "$destination/$reportname.txt"
    echo "" >> "$destination/$reportname.txt"
    echo "copied filenames: " >> "$destination/$reportname.txt"
    echo "  filenames = ${uniqsArr[*]##*/}" >> "$destination/$reportname.txt"
    echo "" >> "$destination/$reportname.txt"
    echo "" >> "$destination/$reportname.txt"



    echo "filenames: "
    for i in "${uniqsArr[@]}"
    do
        filename="${i##*/}"
        dateofCreation=$(stat -c '%w' "$i" | cut -d ' ' -f1 )
        owner=$(stat -c '%U' "$i")

        # echo "$i"

        if [[ "$filename" == *"."* ]] # check if file has an extension
        then
            filename="${filename%.*}"
            ext="${i##*.}" # de extension van de file

            newName="${owner}_${dateofCreation}_${filename}.${ext}"

            j=1
            while [ -f "$destination/$newName" ]
            do
                newName="${owner}_${dateofCreation}_${filename}${j}.${ext}"
                ((j=j+1))
            done

            echo "newname: $newName"
        else
            newName="${owner}_${dateofCreation}_${filename}"

            j=1
            while [ -f "$destination/$newName" ]
            do
                newName="${owner}_${dateofCreation}_${filename}${j}"
                ((j=j+1))
            done
        fi

        echo "copy verbose: " >> "$destination/$reportname.txt"  ## reporting/copying
        if ! cp -v "$i" "$destination/$newName" >> "$destination/$reportname.txt" 2> ~/log.txt
        then
            log "Copy failed!"
        fi
    done

    if [ errorsOccured -eq 1 ]
    then
        echo "There was an error in the execution, for more details check log.txt"
    fi
}
