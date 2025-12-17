#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    :
# Description:
#------------------------------------------------------------------------------

export LANG=C

overall=0
for status_file in /proc/[0-9]*/status; do
  if [[ -f $status_file ]]; then
    swap_mem=$(grep VmSwap "$status_file" | awk '{ print $2 }')
    if [ "$swap_mem" ] && [ "$swap_mem" -gt 0 ]; then
        pid=$(grep Tgid "$status_file" | awk '{ print $2 }')
        name=$(grep Name "$status_file" | awk '{ print $2 }')
        printf "%s\t%20s\t%4s MB\n" "$pid" "$name" "$(((swap_mem+512)/1024))"
    fi
    overall=$((overall+swap_mem))
  fi
done
echo "========================================"
printf "Total Swapped Memory: %14u MB\n" "$(((overall+512)/1024))"
