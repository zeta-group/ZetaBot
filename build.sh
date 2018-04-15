#!/bin/bash

POSITIONAL=
FOLDER="out"
SCPORT="gzdoom"
CVAR=""
IWAD=""
EXTRA=""
SPFILES=""
MAP=""
LZMA=0

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
        -l|--lzma)
        LZMA=1
        shift # past option
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
        -a|--file|--add)
        SPFILES="$SPFILES;$2"
        shift
        shift
        ;;
        -m|--map)
        MAP=$2
        shift
        shift
        ;;
        -c|--cvar)
        if [ -z "$CVAR" ]; then
            CVAR="$2"
        
        else
            CVAR="$CVAR $2"
            
        fi
        shift # past argument
        shift # past value
        ;;
        -e|--extra) # extra source port arguments
        if [ -z "$EXTRA" ]; then
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
BUILDDIR=""

ADDFILE () {
    if [ $# -eq 1 ]; then
        if [ ! -z "$BUILDDIR" ]; then
            f="${BUILDDIR}/${1}"
        
        else
            f="./${1}"
        
        fi
        
        FILES+=($f)

    else
        echo "[WARNING] Invalid call to ADDFILE with ${#} arguments (expected 1)!"
        
    fi
}

ADDFOLDER () {
    if [ ! -z "$BUILDDIR" ]; then
        d="${BUILDDIR}/${1}"
        
    else
        d=$1
    
    fi

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

# Pre-configuration
. ./config.sh
NUMFILES=${#FILES[@]}
FARR=("${FILES[@]}")
FILES=""

for f in "${FARR[@]}"; do
    if [ -z "$FILES" ]; then
        FILES=$f
    
    else
        FILES=$(
            printf "${FILES}"
            printf '\n'
            printf $f
        )
    
    fi

done


owd=$(pwd)

if [ $LZMA -eq 1 ]; then
    PKEXT=7
    
else
    PKEXT=3

fi

out="${owd}/${FOLDER}/${NAME}_v${VERSION}.pk${PKEXT}"

if [ ! -z "$BUILDDIR" ]; then
    echo Moving to build directory.
    cd $BUILDDIR

fi

mkdir -p $FOLDER

# Create output file
echo Adding $NUMFILES files to output \'${out}\'.
rm $out

if [ $LZMA -eq 1 ]; then
    echo $FILES | tr " " "\n" | tar cf $out --lzma -T - || {
        echo "Error building PK7 output!"
        exit 1
    }

else
    zip -9 $out ${FILES} >/dev/null || {
        echo "Error building PK3 output!"
        exit 1
    }
    
fi

# Create launch script
lout="${owd}/${FOLDER}/${NAME}"
echo "#!/bin/bash" >"$lout"
printf "\"${SCPORT}\" -iwad \"${IWAD}\" -file \"./${NAME}_v${VERSION}.pk${PKEXT}\"" >>"$lout"

for cv in $CVAR; do
    printf " +set $(echo $cv | awk -F\= '{print $1}') $(echo $cv | awk -F\= '{print $2}')" >> "$lout"
    
done

(
    IFS=';'
    
    for spf in $SPFILES; do
        if [ ! $spf == "" ]; then
            printf ' -file "' >> "$lout"
            printf $spf >> "$lout"
            printf '"' >> "$lout"
            
        fi
    done
)

for eo in $EXTRA; do
    printf " $(echo $eo | awk -F\= '{print $1}') $(echo $eo | awk -F\= '{print $2}')" >> "$lout"
    
done

if [ ! MAP == "" ]; then
    printf " +map $MAP" >> "$lout"

fi

cd "$owd"
chmod +x "$lout"

# Post-build
if [ -e "./postbuild.sh" ]; then
    . ./postbuild.sh $OUT
    
fi

echo "PK${PKEXT} built succesfully: $out"
