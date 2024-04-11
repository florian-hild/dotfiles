#!/bin/bash

################################################################################
# Kurzbeschr. ....:
# Entwickler .....: F.Hild
# Datum ..........: dd.mm.YYYY
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

# Help
#
help() {
  # Display Help
  echo "Description:"
  echo "  Check if webite or webservice is available / reachable"
  echo
  echo "Usage:"
  echo "  ${0} [OPTION]..."
  echo
  echo "Options:"
  printf "  %-24s %s\n" "-f, --file" "Input file with URLs"
  printf "  %-24s %s\n" "-h, --help" "Display this help and exit"
  printf "  %-24s %s\n" "-v, --verbose" "Print debugging messages"
  printf "  %-24s %s\n" "-V, --version" "Display the version number and exit"
  echo
  echo "Examples:"
  echo "  Zeigt diese Hilfe an"
  echo "  \$${0} --help"
  echo
  echo "  Check single URL"
  echo "  \$${0} https://github.com"
  exit 0
}

check_url() {
  local url=${1// }
  local cacert=${2// }

  if [[ ! ${url} =~ ^https?:// ]]; then
    url="https://${url}"
  fi

  if [[ -z ${cacert// } ]]; then
    STATUS_CODE=$(curl \
      --output /dev/null \
      --silent \
      --write-out "%{http_code}" \
      --connect-timeout 10 \
      --max-time 10 \
      "${url}")
  else
    STATUS_CODE=$(curl \
      --output /dev/null \
      --silent \
      --write-out "%{http_code}" \
      --connect-timeout 10 \
      --max-time 10 \
      --cacert "${cacert}" \
      "${url}")
  fi

  local rc=${?}

  if [[ ${STATUS_CODE// } =~ ^2[0-9]{2}$ ]]; then
    echo -e "\033[0;32m[OK - ${STATUS_CODE}] [${url}]\033[m"
  elif [[ ${STATUS_CODE// } =~ ^3[0-9]{2}$ ]]; then
    echo -e "\e[0;38;5;215m[REDIRECT - ${STATUS_CODE}] [${url}]\033[m"
  elif [[ ${STATUS_CODE// } =~ ^4[0-9]{2}$ ]]; then
    echo -e "\033[0;31m[CLIENT ERROR - ${STATUS_CODE}] [${url}]\033[m"
  elif [[ ${STATUS_CODE// } =~ ^5[0-9]{2}$ ]]; then
    echo -e "\033[0;31m[SERVER ERROR - ${STATUS_CODE}] [${url}]\033[m"
  elif [[ ${STATUS_CODE// } =~ ^5[0-9]{2}$ ]]; then
    echo -e "\033[0;31m[SERVER ERROR - ${STATUS_CODE}] [${url}]\033[m"
  elif [[ ${STATUS_CODE// } =~ ^000$ ]]; then
    if [[ ${rc} == 6 ]]; then
        msg="curl: (6) Could not resolve host"
    elif [[ ${rc} == 28 ]]; then
        msg="curl: (28) Operation timed out"
    elif [[ ${rc} == 60 ]]; then
        msg="curl: (60) SSL certificate problem"
    else
        msg="curl: (${rc})"
    fi
    echo -e "\033[0;31m[${msg} - ${STATUS_CODE}] [${url}]\033[m"
  else
    echo -e "[${STATUS_CODE}] [${url}]\033[m"
  fi
}

################################################################################
#                                    Start                                     #
################################################################################
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ ${#} -eq "0" ]] || [[ ${@} == "-" ]] || [[ ${@} == "--" ]]; then
        echo "Keine gueltige Option angegeben !!"
        echo -e " "
        help
        exit 2
    fi

    OPTS="$(getopt -o "f:hvV" --long "file:,help,verbose,version" -n "${progname}" -- "${@}")"
    if [[ "${?}" != "0" ]] ; then
        echo "Fehler: Unbekannte Option ${1}" >&2
        exit 2
    fi
    eval set -- "$OPTS"

    while true; do
        case "${1}" in
        -f | --file)
            declare -r urls_file=${2}
            shift 2
            ;;
        -h | --help)
            help
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
            echo "Fehler: Unbekannte Option ${1}" >&2
            exit 2
            ;;
        esac
    done
fi

if [[ -z ${urls_file// } ]] && [[ ! -z ${1// } ]]; then
  declare url="${1}"
  declare cacert="${2}"
  check_url "${url}" "${cacert}"
else
  /bin/grep -v -e "^\s*#" -e "^\s*$" ${urls_file// } | while read line ; do
    # Remove everything after first space and add ; to the end of line
    line="${line%% *};"
    url=$(echo ${line}|cut -d';' -f1)
    cacert=$(echo ${line}|cut -d';' -f2)
    check_url "${url}" "${cacert}"
  done
fi

exit

