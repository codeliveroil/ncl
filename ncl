#!/bin/bash

###########################################################
#
# Copyright (c) 2017 codeliveroil. All rights reserved.
#
# This work is licensed under the terms of the MIT license.
# For a copy, see <https://opensource.org/licenses/MIT>.
#
# ---------------------------------------------------------
#
# ncl - A navigable version of the in-built calendar (cal)
#
###########################################################

# Convenience method to add trailing spaces to each line of
# cal's output so that we don't have to clear out the entire
# line (with tput el) when redrawing. Clearing out the entire
# line causes a ghastly flicker effect.
print_cal () {
  #20 is sufficient but repeated key presses will mess up the display
  #30 will help clear up some of the mess. Avoid using stty -echo for such a simple program.
  local max=30
  IFS=$(echo -en "\n\b")
  local i=0
  for l in $(cal ${opt} $1 $2); do
    printf "%-${max}s\n" "${l}"
    i=$(( ${i} + 1 ))
  done
  while [ ${i} -lt $3 ]; do
    printf "%-${max}s\n" ""
    i=$(( ${i} + 1 ))
  done
}

# Parse args
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "A navigable version of the in-built calendar (cal)."
  echo "Usage: $(basename ${0}) [month [year]]"
  echo "       <- (left arrow) : Previous month"
  echo "       -> (right arrow): Next month"
  echo "       q               : Quit"
  exit
fi

curr_month=$(date +%m)
curr_year=$(date +%Y)
[ "$1" == "" ] && month=${curr_month} || month=$1
[ "$2" == "" ] && year=${curr_year} || year=$2

# Disable highlighting if linux
opt=""
if [ "$(uname)" == "Linux" ]; then
  opt="-h"
fi

# Render cal
echo ""
while true; do
  lc=$(cal ${month} ${year} | wc -l | xargs)
  [ $? -ne 0 ] && exit 1
  if [ ${month} -eq ${curr_month} ] && [ ${year} -eq ${curr_year} ]; then
    print_cal ${month} ${year} ${lc} | grep --color=auto -C10 -w "$(date +%-d)"
  else
    print_cal ${month} ${year} ${lc}
  fi
  echo "<-:prev ->:next q:go"
  key=
  while true; do
    read -s -n1 key
    if [ "${key}" == $'\e' ]; then #Check if this is a special key press; i.e. if key=^[ (escape)
      read -s -n2 key #arrow keys and other speical keys will register as "^[[X".
    fi
    case ${key} in
      "[D") #left arrow
        if [ ${year} -eq 1 ] && [ ${month} -eq 1 ]; then #check for underflow
          break
        fi
        month=$(( 10#${month} - 1 ))
        if [ ${month} -eq 0 ]; then
          month=12
          year=$(( 10#${year} - 1 ))
        fi
        break
        ;;
      "[C") #right arrow
        if [ ${year} -eq 9999 ] && [ ${month} -eq 12 ]; then #check for overflow
          break
        fi
        month=$(( 10#${month} + 1 ))
        if [ ${month} -eq 13 ]; then
          month=1
          year=$(( 10#${year} + 1 ))
        fi
        break
        ;;
      "q")
        echo ""
        exit
        ;;
    esac
  done
  for i in $(seq 0 ${lc}); do
    tput cuu1
  done
done
