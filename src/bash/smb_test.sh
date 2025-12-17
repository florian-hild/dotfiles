#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : 22-11-2021
# Description:
#------------------------------------------------------------------------------

export LANG=C
declare -r __SCRIPT_VERSION__='1.0'

# help(exit_code)
# Print help message and exit
help() {
  local -r exit_code="${1:-0}"
  cat << EOF
Test SMB/CIFS share access permissions

Usage:
  ${0} [options]

Options:
  -d, --domain <DOMAIN>          Set domain (Default: SAMBA)
  -h, --help                     Display this help and exit
  -p, --password <PASSWORD>      Set password (required)
  -u, --user <USERNAME>          Set username (required)
  -v, --verbose                  Print debugging messages
  -V, --version                  Display version and exit
  -s, --server <SERVER>          Set server (Default: localhost)

Examples:
  Test SMB shares on server
  \$ ${0} -s 10.0.0.100 -u testdomain -p Secret123

EOF
  exit "${exit_code}"
}

test_smb_share(){
  echo " Username: ${username}"
  echo " Server:   ${server}"
  echo ""
  echo " Shares:"
  echo " -------------------------------------------------"

  cd "${TMPDIR:-/tmp}" || exit
  touch tmp_$$.tmp           # Required locally to copy to target

  smbclient -L "$server" -g -A <( echo "username=$username"; echo "password=$password" ) 2>/dev/null |
    awk -F'|' '$1 == "Disk" {print $2}' |
    while IFS= read -r share; do

      if smbclient "//$server/$share/" "$password" -U "$username" -c "dir" >/dev/null 2>&1; then
        status=READ
        # Try uprating to read/write
        if smbclient "//$server/$share/" "$password" -U "$username" -c "put tmp_$$.tmp ; rm tmp_$$.tmp" >/dev/null 2>&1; then
          status=WRITE
        fi
      else
        status=NONE
      fi

      case "$status" in
        READ) echo " read  access at //${server}/${share}" ;;
        WRITE) echo " write access at //${server}/${share}" ;;
        *) echo " no    access at //${server}/${share}" ;;
      esac
    done

  rm -f tmp_$$.tmp
}

################################################################################
#                                    Start                                     #
################################################################################
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    domain="SAMBA"
    password=""
    username=""
    server="localhost"

    while [[ $# -gt 0 ]]; do
        case "${1}" in
        -d | --domain)
            domain="${2}"
            shift 2
            ;;
        -h | --help)
            help 0
            ;;
        -p | --password)
            password="${2}"
            shift 2
            ;;
        -u | --user)
            username="${2}"
            shift 2
            ;;
        -v | --verbose)
            set -xv  # Set xtrace and verbose mode.
            shift
            ;;
        -V | --version)
            echo "${__SCRIPT_VERSION__}"
            exit 0
            ;;
        -s | --server)
            server="${2}"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Error: Unknown option ${1}" >&2
            help 2
            ;;
        *)
            break
            ;;
        esac
    done

    if [[ -z "${username// }" ]] || [[ -z "${password// }" ]]; then
      echo "Parameter user oder password muss gesetzt sein!"
      exit 1
    fi

    server=${server:-"localhost"}
    username=${domain:-"SAMBA"}\\${username}

    test_smb_share

    exit
fi
