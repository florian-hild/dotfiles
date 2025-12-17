#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : 27-01-2023
# Description:
#------------------------------------------------------------------------------

export LANG=C

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
# shellcheck disable=SC2029
/usr/bin/ssh "${REMOTE_HOST}" "/bin/cat ${REMOTE_FILE}" | ${DIFF_CMD} --ignore-blank-lines --ignore-space-change --ignore-all-space "${LOCAL_FILE}" -
