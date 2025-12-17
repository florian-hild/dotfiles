#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : 27-02-2024
# Description: Download from redhat.com
#-------------------------------------------------------------------------------

export LANG=C

# help(exit_code)
# Print help message and exit
help() {
  local -r exit_code="${1:-0}"
  cat << EOF
Download Red Hat ISO from redhat.com

Usage:
  ${0} [options]

Options:
  --checksum-sha256 <sha256>     SHA-256 checksum from Red Hat ISO image (required)
  -h, --help                     Display this help and exit
  -v, --verbose                  Print debugging messages
  -V, --version                  Display version and exit

Examples:
  Get Red Hat offline API token from https://access.redhat.com/management/api
  \$ ${0} --checksum-sha256 0bb7600c3187e89cebecfcfc73947eb48b539252ece8aab3fe04d010e8644ea9

EOF
  exit "${exit_code}"
}

# main()
# Start of script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ ${#} -eq "0" ]] || [[ ${*} == "-" ]] || [[ ${*} == "--" ]]; then
    echo "Syntax or usage error (1)" >&2
    echo
    help 128
  fi

  if ! OPTS="$(getopt -o 'hvV' --long 'checksum-sha256:,help,verbose,version' -n "${0}" -- "${@}")"; then
    echo "Syntax or usage error (2)" >&2
    echo
    help 128
  fi
  eval set -- "$OPTS"

  while true; do
    case "${1}" in
    --checksum-sha256)
      declare -r checksum_sha256="${2}"
      shift 2
      ;;
    -h | --help)
      help 0
      ;;
    -v | --verbose)
      set -xv  # Set xtrace and verbose mode.
      shift
      ;;
    -V | --version)
      echo "${__SCRIPT_VERSION__}"
      exit 0
      ;;
    -- )
      shift
      break
      ;;
    *)
      echo "Syntax or usage error (3)" >&2
      echo
      help 128
      ;;
    esac
  done
fi

if [[ -z "${checksum_sha256// }" ]]; then
  echo "Error: You must specify a SHA-265 checksum from the ISO image."
  echo
  help 128
fi

echo "You can get a new offline API token from this url: https://access.redhat.com/management/api"
read -r -p "Enter Red Hat offline API token: " offline_token
if [[ -z "${offline_token// }" ]]; then
  echo "Error: Variable \"offline_token\" not set."
  exit 1
fi

# get an access token
access_token=$(curl --silent \
                    --data grant_type=refresh_token \
                    --data client_id=rhsm-api \
                    --data refresh_token="${offline_token}" \
                    https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token | jq -r '.access_token')

# get the filename and download url
image=$(curl --silent \
             --header "Authorization: Bearer ${access_token}" \
             "https://api.access.redhat.com/management/v1/images/${checksum_sha256}/download")
filename=$(echo "${image}" | jq -r .body.filename)
[[ -z "${filename// }" ]] && echo -e "Error: Could not get access token. Please check your API Token.\n${image}\n"
url=$(echo "${image}" | jq -r .body.href)

# download the file
echo "Downloading ${filename} ..."
curl --output "${filename}" "${url}"

exit

