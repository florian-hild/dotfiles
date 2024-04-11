#!/bin/bash

################################################################################
# Kurzbeschr. ....:
# Entwickler .....: F.Hild
# Datum ..........: 27.01.2013
# Ablageort ......:
# Git-Repo .......:
# Review .........:
# Beschreibung ...:
#
# Aenderung ......:
# youTrack .......:
# confluence .....:
################################################################################

export LANG=C
declare -r __SCRIPT_VERSION__='1.0'

if [[ -z "${1// }" ]] || [[ -z "${2// }" ]] || [[ -z "${3// }" ]]; then
  echo "$0 <local file> <remote file> <remote host>"
  exit 1
fi

LOCAL_FILE=${1}
REMOTE_FILE=${2}
REMOTE_HOST=${3}

if command -v colordiff &> /dev/null; then
  DIFF_CMD="/usr/bin/colordiff"
else
 DIFF_CMD="/usr/bin/diff"
fi

echo "diff ${LOCAL_FILE} ${REMOTE_FILE} at ${REMOTE_HOST}"
/usr/bin/ssh ${REMOTE_HOST} "/bin/cat ${REMOTE_FILE}" | ${DIFF_CMD} -EZBbw ${LOCAL_FILE} -
