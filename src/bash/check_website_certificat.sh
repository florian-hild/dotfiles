#!/bin/bash

################################################################################
# Kurzbeschr. ....:
# Entwickler .....: F.Hild
# Datum ..........: 21.01.2023
# Ablageort ......:
# Git-Repo .......:
# Review .........:
# Beschreibung ...:
#
################################################################################

export LANG=C
declare -r __SCRIPT_VERSION__='1.0'


if [[ -z "$*" ]]; then
  echo "Domain name missing"
  exit 1
fi
now_epoch=$( date +%s )

for dns in $*; do
  echo "Checking certificate for $dns"

  dig +noall +answer $dns | while read _ _ _ _ ip; do
    echo -n "$ip:"
    expiry_date=$( echo | openssl s_client -showcerts -servername $dns -connect $ip:443 2>/dev/null | openssl x509 -inform pem -noout -enddate | cut -d "=" -f 2 )
    echo -n " $expiry_date"
    expiry_epoch=$( date -d "$expiry_date" +%s )
    expiry_days="$(( ($expiry_epoch - $now_epoch) / (3600 * 24) ))"
    echo "    $expiry_days days"
  done
done
