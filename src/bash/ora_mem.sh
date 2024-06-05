#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : 24-05-2024
# Description:
#-------------------------------------------------------------------------------

export LANG=C
declare -r __SCRIPT_VERSION__='1.0'

if [[ "${LOGNAME}" != "root" ]] || [[ ! "$(id -u)" -eq "0" ]]; then
  echo "Script must be started as root user!"
  exit
fi

sids=$(pgrep -u oracle -l ora_pmon | awk '{print substr($NF,10)}')
total_mem_kb=0

for sid in ${sids} ; do
  pids=$(pgrep -u oracle -f ${sid^^})
  mem_kb=$(pmap ${pids} 2>&1 | grep "K " | sort | awk '{print $1 " " substr($2,1,length($2)-1)}' | uniq | awk ' BEGIN { sum=0 } { sum+=$2} END {print sum}')

  # Convert KB to GB
  mem_gb=$(echo "scale=2; ${mem_kb} / (1024 * 1024)" | bc)


  echo "SID: ${sid^^}: ${mem_gb}"
  total_mem_kb=$(expr ${total} + ${mem_kb})
done

# Convert KB to GB
total_mem_gb=$(echo "scale=2; ${total_mem_kb} / (1024 * 1024)" | bc)

echo "+------------------------+"
echo "Total Memory:  ${total_mem_gb} GB"
