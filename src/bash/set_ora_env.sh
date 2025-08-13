#!/usr/bin/env bash

################################################################################
# Developer ......: F.Hild
# Created ........: 11.08.2023
# Description ....: Set oracle environment
################################################################################

export LANG=C

declare -r __SCRIPT_VERSION__='1.0'

# help(exit_code)
# Print help message and exit
help() {
  local -r exit_code="${1:-0}"
  # Print help text
  cat << EOF
Usage:
  ${0} [options]

Options:
  -c, --characterset <LANG>      Set utf8 or iso characterset (Default: utf8)
  -h, --help                     Display this help and exit
  --home <PATH>                  Set path to Oracle home (required)
  --ldpath <PATH>                Set LD_LIBRARY_PATH (Default: \$ORACLE_HOME/lib)
  -s, --sid <ORACLE_SID>         Set Oracle SID
  --tns_admin <PATH>             Set TNS_ADMIN (Default: \$ORACLE_HOME/network/admin)
  -v, --verbose                  Print debugging messages
  -V, --version                  Display version and exit

Examples:
  Set Oracle environment
  \$ ${0} --home /opt/oracle/product/19.3.0/client_64
EOF
  exit ${exit_code}
}

# main()
# Start of script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ ${#} -eq "0" ]] || [[ ${@} == "-" ]] || [[ ${@} == "--" ]]; then
    echo "Syntax or usage error (1)" >&2
    echo
    help 128
  fi

  OPTS="$(getopt -o "c:hs:vV" --long "characterset:,help,home:,ldpath:,sid:,tns_admin:,verbose,version" -n "${progname}" -- "${@}")"
  if [[ "${?}" != "0" ]] ; then
    echo "Syntax or usage error (2)" >&2
    echo
    help 128
  fi
  eval set -- "$OPTS"

  while true; do
    case "${1}" in
    -c | --characterset)
      declare -r characterset="${2}"
      shift 2
      ;;
    -h | --help)
      help 0
      ;;
    --home)
      declare -r oracle_home="${2}"
      shift 2
      ;;
    --ldpath)
      declare -r ld_lib_path="${2}"
      shift 2
      ;;
    -s | --sid)
      declare -r oracle_sid="${2}"
      shift 2
      ;;
    --tns_admin)
      declare -r tns_admin="${2}"
      shift 2
      ;;
    -v | --verbose)
      declare -r verbose="1"
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

if [[ -z "${oracle_home// }" ]]; then
  echo "Error: You must specify a path to Oracle home."
  echo
  help 128
fi

if [[ -d "${oracle_home// }" ]]; then
  echo "export ORACLE_HOME=\"${oracle_home// }\""
  echo "export SQLPATH=\"${oracle_home// }/rdbms/admin:${SQLPATH}\""
  echo "export PATH=\"${oracle_home// }/bin:${oracle_home// }/OPatch:${PATH}\""
else
  echo "Error: Directory \"${oracle_home// }\" not found"
  exit 1
fi

if [[ -z "${characterset// }" ]] || [[ "${characterset// }" == "utf8" ]]; then
  echo "export NLS_LANG='AMERICAN_AMERICA.UTF8'"
elif [[ "${characterset// }" == "iso" ]]; then
  echo "export NLS_LANG='AMERICAN_AMERICA.WE8ISO8859P15'"
else
  echo "Error: Characterset \"${characterset// }\" not found."
  echo
  help 128
fi

echo "export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'"

if [[ -z "${ld_lib_path// }" ]]; then
  echo "export LD_LIBRARY_PATH=\"${oracle_home}:${oracle_home}/lib:${LD_LIBRARY_PATH}\""
elif [[ -d "${ld_lib_path// }" ]]; then
  echo "export LD_LIBRARY_PATH=\"${ld_lib_path}:${LD_LIBRARY_PATH}\""
else
  echo "Error: ld_lib_path \"${ld_lib_path// }\" not found."
  echo
  help 1
fi

if [[ -n "${oracle_sid// }" ]]; then
  echo "export ORACLE_SID=\"${oracle_sid^^}\""
fi

if [[ -z "${tns_admin// }" ]]; then
  echo "export TNS_ADMIN=\"${oracle_home}/network/admin\""
elif [[ -d "${tns_admin// }" ]]; then
  echo "export TNS_ADMIN=\"${tns_admin}\""
else
  echo "Error: tns_admin \"${tns_admin// }\" not found."
  echo
  help 1
fi



