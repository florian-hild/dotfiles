#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : 23-04-2025
# Description:
#-------------------------------------------------------------------------------

export LANG=C
declare -r __SCRIPT_VERSION__='1.0'

for dev in $(ls -1 /sys/class/net | LANG=C sort); do
    [[ ! -e "/sys/class/net/${dev}/device" ]] && continue

    description=$(udevadm info /sys/class/net/${dev} | awk -F= '/ID_VENDOR_FROM_DATABASE=/ {vendor=$2} /ID_MODEL_FROM_DATABASE=/ {model=$2} END {print vendor ", " model}')
    state=$(cat /sys/class/net/${dev}/operstate)
    hw_address=$(cat /sys/class/net/${dev}/address)
    ip_address="$(ip -br addr show ${dev} | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print ""}'
)"

    # Output:
    cat << EOF
Device:      ${dev:--}
Description: ${description:--}
State:       ${state:--}
Mac address: ${hw_address:--}
IP Address:  ${ip_address:--}

EOF
done

