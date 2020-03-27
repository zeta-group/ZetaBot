#!/bin/bash
if [ ! -e acs/last_source.sha512 ] || [ $(sha512sum < source/ZETAACS.acs | head -c128) != $(cat acs/last_source.sha512) ]; then
    if [ $PLATFORM == MINGW ] || [ $PLATFORM == CYGWI ]; then
        ./acc.exe -i ./STDACS source/ZETAACS.acs acs/ZETAACS.o && (
            sha512sum < source/ZETAACS.acs | head -c128 > acs/last_source.sha512
        )
        
    else
        ./acc -i ./STDACS source/ZETAACS.acs acs/ZETAACS.o && (
            sha512sum < source/ZETAACS.acs | head -c128 > acs/last_source.sha512
        )
        
    fi
fi