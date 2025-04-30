#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : 30-04-2025
# Description: Wrapper for Oracle SQL*Plus via Dockerized Instant Client
#-------------------------------------------------------------------------------

set -euo pipefail
export LANG=C
declare -r __SCRIPT_VERSION__='1.0'

# Default to version 23 if not set
oracle_client_version="${ORACLE_CLIENT_VERSION:-23}"
oracle_client_image="ghcr.io/oracle/oraclelinux9-instantclient:${oracle_client_version}"

# Detect container runtime
if command -v docker &>/dev/null; then
  CONTAINER_CLI="docker"
elif command -v podman &>/dev/null; then
  CONTAINER_CLI="podman"
else
  echo "ERROR: Neither 'docker' nor 'podman' is installed or available in PATH."
  exit 1
fi

if [[ -z "${TNS_ADMIN// }" ]]; then
  echo "ERROR: The environment variable 'TNS_ADMIN' is not set or is empty."
  echo "Please set 'TNS_ADMIN' to the full path of your Oracle Instant Client's network/admin directory."
  exit 1
fi

if [[ -d "${HOME}/.dotfiles/oracle/sql" ]]; then
  SQLPATH_OPTS="-e SQLPATH=/opt/oracle/sql -v ${HOME}/.dotfiles/oracle/sql:/opt/oracle/sql"
fi

set -x
${CONTAINER_CLI} run -it --rm \
  -v "${TNS_ADMIN}:/opt/oracle/instantclient/network/admin" \
  -v '/etc/localtime:/etc/localtime:ro' \
  -e 'TNS_ADMIN=/opt/oracle/instantclient/network/admin' \
  -e 'TZ=Europe/Berlin' \
  ${SQLPATH_OPTS} \
  "${oracle_client_image}" \
  sqlplus "${@}"
