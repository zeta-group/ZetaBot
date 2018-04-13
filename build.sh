#!/bin/bash

POSITIONAL=
FOLDER="out"
SCPORT="gzdoom"
CVAR=""
IWAD=""
EXTRA=""

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -h|--help)
        echo
        echo Syntax:
        echo
        echo
        echo "  ./build.sh \[-f <output folder : out>\] \[-s \<path to source port : gzdoom\>\] -i \<path to the mod's IWAD\> \[-c \<additional cvar\>\=\<value\> \[...\]] \[-e \<source port option\>=\<value\> \[...\]\]"
        echo
        echo For example:
        echo
        echo "    ./build.sh -f out -s gzdoom -i /usr/games/doom/doom2.wad -c zb_debug=1 -e \"-nomonsters\" -e \"-skill=1\" -e \"+map=MAP18\""
        echo
        exit 0
        ;;
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
        -e|--extra) # extra source port arguments
        if [ -z $ ]; then
            EXTRA="$2"
        
        else
            EXTRA="$EXTRA $2"
            
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

FILES=()
BUILDDIR="."

ADDFILE () {
    f="${BUILDDIR}/${1}"

    if [ $# -eq 1 ]; then
        FILES+=($(echo -e "\n$f"))

    else
        echo "[WARNING] Invalid call to ADDFILE with ${#} arguments (expected 1)!"
        
    fi
}

ADDFOLDER () {
    d="${BUILDDIR}/${1}"

    if [ $# -eq 1 ]; then
        for f in $(find $d -type f); do
            ADDFILE $(echo $f | cut -c $(expr 1 + ${#BUILDDIR})-)
            
        done
        
    elif [ $# -eq 2 ]; then
        for f in $(find $d -type f -name $2); do
            ADDFILE $(echo $f | cut -c $(expr 1 + ${#BUILDDIR})-)
            
        done
    
    else
        echo "[WARNING] Invalid call to ADDFOLDER with ${#} arguments (expected 1 or 2)!"
        
    fi
}

# Build compilation
if [ -e "./compile.sh" ]; then
    . ./compile.sh >/dev/null
    
fi

# Build PK3
. ./config.sh
NUMFILES=${#FILES}
FILES=${FILES[*]}

owd=$(pwd)
out="${owd}/${FOLDER}/${NAME}_v${VERSION}.pk3"

cd $BUILDDIR

mkdir -p $FOLDER

# Create output file
echo Adding $NUMFILES files to output \'${out}\'.
zip $out $FILES >/dev/null

# Create launch script
lout="${owd}/${FOLDER}/${NAME}"
echo "#!/bin/bash" >"$lout"
printf "\"${SCPORT}\" -iwad \"${IWAD}\" -file \"./${NAME}_v${VERSION}.pk3\"" >>"$lout"

for cv in $CVAR; do
    printf " +set $(echo $cv | awk -F\= '{print $1}') $(echo $cv | awk -F\= '{print $2}')" >> "$lout"
    
done
    
for eo in $EXTRA; do
    printf " $(echo $eo | awk -F\= '{print $1}') $(echo $eo | awk -F\= '{print $2}')" >> "$lout"
    
done

cd "$owd"
chmod +x "$lout"

# Post-build
if [ -e "./postbuild.sh" ]; then
    . ./postbuild.sh $OUT
    
fi

echo "PK3 built succesfully: $out"
