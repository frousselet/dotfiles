#!/bin/bash

##############
#
# batch-renamer.sh
#
# This script will rename all files in $1 like YYYY-MMDD-HHMMSS-<PARENT_DIR>.<EXT>
# where PARENT_DIR is the parent directory of the file and EXT is the file extension.
# If there is a .dop (DxO PhotoLab edition metadata file), it will be renamed as the original file,
# ie. YYYY-MMDD-HHMMSS-<PARENT_DIR>.dop.
#
##


if [ ! command -v exiftool >/dev/null 2>&1 ]; then
    echo -e "[ ❌ ] Exiftool not food."
    echo -e "       Please install it and try again: https://www.sno.phy.queensu.ca/~phil/exiftool/install.html"
    echo -e "       [Debian] apt install exiftool"
    echo -e "       [MacOS]  brew install exiftool"
    exit 65
fi

_spin()
{
  local -r pid="${1}"
  local -r delay='0.1'
  local spinstr='\|/-'
  local temp
  while ps a | awk '{print $1}' | grep -q "${pid}"; do
    temp="${spinstr#?}"
    printf "[ %c ] Renaming files..." "${spinstr}"
    spinstr=${temp}${spinstr%"${temp}"}
    sleep "${delay}"
    printf "\r"
  done

  wait "$1"
  exit $?
}

_proceed_file() (

  raw_file=$2

  extention=$(echo $raw_file | awk -F. '{print (NF>1?$NF:"no extension")}')
  if [ $extention != "dop" ]; then

    if [ $3 -lt 10 ]; then
      incremental="000${3}"
    elif [ $3 -lt 100 ]; then
      incremental="00${3}"
    elif [ $3 -lt 1000 ]; then
      incremental="0${3}"
    else
      incremental=$3
    fi

    raw_created_date=$(exiftool -CreateDate "$raw_file" | cut -c35- | sed 's/ /:/g')
    created_year=$(echo "$raw_created_date" | cut -d ":" -f "1")
    created_mounth=$(echo "$raw_created_date" | cut -d ":" -f "2")
    created_day=$(echo "$raw_created_date" | cut -d ":" -f "3")
    created_hour=$(echo "$raw_created_date" | cut -d ":" -f "4")
    created_minute=$(echo "$raw_created_date" | cut -d ":" -f "5")
    created_second=$(echo "$raw_created_date" | cut -d ":" -f "6")

    mv "$raw_file" "${1}/${created_year}-${created_mounth}${created_day}-${created_hour}${created_minute}-${incremental}_$(basename -- $1).${extention}"
    mv "$raw_file.dop" "${1}/${created_year}-${created_mounth}${created_day}-${created_hour}${created_minute}-${incremental}_$(basename -- $1).${extention}.dop" 2>/dev/null | true

    return "$file_count"

  fi

)

_rename()(

  if [ -z "$1" ]; then

    echo -e "[ ❌ ] No directory provided as argument!"
    echo -e "       Usage: ${0} <DIRECTORY>"

    exit 22

  fi

  if [ ! -d "$1" ]; then

    echo -e "[ ❌ ] ${1} is not a directory!"
  
    exit 20

  fi

  file_count=1

  for raw_file in "$1"/*; do

    extention=$(echo $raw_file | awk -F. '{print (NF>1?$NF:"no extension")}')

    if [ $extention != "dop" ]; then

      _proceed_file "$1" "$raw_file" "$file_count" &
      file_count=$(( $file_count + 1 ))

    fi

    wait

  done

  echo -e "\r[ 🍻 ] Done! ${file_count} files renamed."

  exit 0
)

_rename "$1" &
_spin "$!"
