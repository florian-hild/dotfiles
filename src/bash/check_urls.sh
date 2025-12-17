#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    :
# Description:
#------------------------------------------------------------------------------

export LANG=C
declare -r __SCRIPT_VERSION__='1.0'

# help(exit_code)
# Print help message and exit
help() {
  local -r exit_code="${1:-0}"
  cat << EOF
Check if website or webservice is available / reachable

Usage:
  ${0} [options] [URL]

Options:
  -f, --file <FILE>              Input file with URLs
  -h, --help                     Display this help and exit
  -v, --verbose                  Print debugging messages
  -V, --version                  Display version and exit

Examples:
  Check single URL
  \$ ${0} https://github.com

  Check URLs from file
  \$ ${0} --file urls.txt

EOF
  exit "${exit_code}"
}

check_url() {
  local url="${1}"
  local cacert="${2}"

  # Remove leading/trailing whitespace
  url="${url#"${url%%[![:space:]]*}"}"
  url="${url%"${url##*[![:space:]]}"}"
  cacert="${cacert#"${cacert%%[![:space:]]*}"}"
  cacert="${cacert%"${cacert##*[![:space:]]}"}"

  if [[ ! ${url} =~ ^https?:// ]]; then
    url="https://${url}"
  fi

  local status_code
  local rc

  if [[ -z ${cacert} ]]; then
    status_code=$(curl \
      --output /dev/null \
      --silent \
      --write-out "%{http_code}" \
      --connect-timeout 10 \
      --max-time 10 \
      "${url}")
    rc=$?
  else
    status_code=$(curl \
      --output /dev/null \
      --silent \
      --write-out "%{http_code}" \
      --connect-timeout 10 \
      --max-time 10 \
      --cacert "${cacert}" \
      "${url}")
    rc=$?
  fi

  # Color codes
  local green='\033[0;32m'
  local orange='\033[0;38;5;215m'
  local red='\033[0;31m'
  local reset='\033[0m'

  if [[ ${status_code} =~ ^2[0-9]{2}$ ]]; then
    printf "${green}[OK - %s] [%s]${reset}\n" "${status_code}" "${url}"
  elif [[ ${status_code} =~ ^3[0-9]{2}$ ]]; then
    printf "${orange}[REDIRECT - %s] [%s]${reset}\n" "${status_code}" "${url}"
  elif [[ ${status_code} =~ ^4[0-9]{2}$ ]]; then
    printf "${red}[CLIENT ERROR - %s] [%s]${reset}\n" "${status_code}" "${url}"
  elif [[ ${status_code} =~ ^5[0-9]{2}$ ]]; then
    printf "${red}[SERVER ERROR - %s] [%s]${reset}\n" "${status_code}" "${url}"
  elif [[ ${status_code} =~ ^000$ ]]; then
    local msg
    case ${rc} in
      6)  msg="curl: (6) Could not resolve host" ;;
      28) msg="curl: (28) Operation timed out" ;;
      60) msg="curl: (60) SSL certificate problem" ;;
      77) msg="curl: (77) SSL CA cert problem" ;;
      *)  msg="curl: (${rc})" ;;
    esac
    printf "${red}[%s - %s] [%s]${reset}\n" "${msg}" "${status_code}" "${url}"
  else
    printf "[%s] [%s]\n" "${status_code}" "${url}"
  fi
}

################################################################################
#                                    Start                                     #
################################################################################
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    urls_file=""

    while [[ $# -gt 0 ]]; do
        case "${1}" in
        -f | --file)
            urls_file="${2}"
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

    # Check if URL provided as argument
    if [[ -n ${1} ]]; then
        url="${1}"
        cacert="${2:-}"
        check_url "${url}" "${cacert}"
        exit 0
    fi

    # Check if file provided
    if [[ -z ${urls_file} ]]; then
        echo "Error: No URL or file specified" >&2
        help 1
    fi

    if [[ ! -f ${urls_file} ]]; then
        echo "Error: File '${urls_file}' not found" >&2
        exit 1
    fi

    # Process URLs from file
    grep -v -e "^\s*#" -e "^\s*$" "${urls_file}" | while IFS= read -r line; do
        # Parse line: URL;cacert (cacert is optional)
        url="${line%%;*}"
        cacert="${line#*;}"

        # If no semicolon found, cacert will equal url
        [[ ${cacert} == "${url}" ]] && cacert=""

        check_url "${url}" "${cacert}"
    done
fi

exit

