#!/bin/bash

POSITIONAL=
FOLDER="out"
SCPORT="gzdoom"
CVAR=""
IWAD=""

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -f|--folder)
        FOLDER="$2"
        shift # past argument
        shift # past value
        ;;
        -s|--sourceport)
        SCPORT="$2"
        shift # past argument
        shift # past value
        ;;
        -i|--iwad)
        IWAD="$2"
        shift # past argument
        shift # past value
        ;;
        -c|--cvar)
        if [ -z $CVAR ]; then
            CVAR="$2"
        
        else
            CVAR="$CVAR $2"
            
        fi
        
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done


set -- "${POSITIONAL[@]}" # restore positional parameters

FILES=

ADDFILE () {
    if [ $# -eq 1 ]; then
        FILES="${FILES}$1\\n"
        
    else
        echo "[WARNING] Invalid call to ADDFILE with ${#} arguments (expected 1)!"
        
    fi
}

ADDFOLDER () {
    if [ $# -eq 1 ]; then
        for f in $(find $1); do
            ADDFILE $f
            
        done
        
    elif [ $# -eq 2 ]; then
        for f in $(find $1 -name $2); do
            ADDFILE $f
            
        done
    
    else
        echo "[WARNING] Invalid call to ADDFOLDER with ${#} arguments (expected 1 or 2)!"
        
    fi
}

# Build PK3
. ./config.sh
out="./${FOLDER}/${NAME}_v${VERSION}.pk3"

mkdir -p $FOLDER
echo -e $FILES | zip -@ $out

# Create launch script
lout="${FOLDER}/${NAME}"
printf "${SCPORT} -iwad ${IWAD} -file ./${NAME}v${VERSION}.pk3" > $lout

for cv in $CVAR; do
    printf " +set $(echo $cv | awk -F\= '{print $1}') $(echo $cv | awk -F\= '{print $2}')" >> $lout
    
done

chmod +x $lout

# Post-build
if [ -e "./postbuild.sh" ]; then
    . ./postbuild.sh $OUT
    
fi

echo "PK3 built succesfully: $out"
