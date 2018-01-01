#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
read -r -d '' help << EOM
Usage: $0 <filename>
EOM
echo "$help"
exit 1
fi

file="$1"
filename=`basename $file`

fileabs=`readlink -f $file`
filedir=$(basename $(dirname "$fileabs"))/"$filename"
include_guard=`echo $filedir | tr '[:lower:]' '[:upper:]' | sed 's/\./_/g' | sed 's/\//_/g'`

read -r -d '' content << EOM
/*! $filename */

#ifndef $include_guard
#define $include_guard

#endif/*$include_guard*/
EOM

printf "$content" > $file
