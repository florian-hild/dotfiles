#!/bin/bash

################################################################################
# Kurzbeschr. ....:
# Entwickler .....: F.Hild
# Datum ..........: 05-09-2022
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
  echo "  Encrypt string with ansible-vault"
  echo
  echo "Usage:"
  echo "  ${0} [OPTION]..."
  echo
  echo "Options:"
  printf "  %-24s %s\n" "-h, --help" "Display this help and exit"
  printf "  %-24s %s\n" "-v, --verbose" "Print debugging messages"
  printf "  %-24s %s\n" "-V, --version" "Display the version number and exit"
  echo
  echo "Examples:"
  echo "  Zeigt diese Hilfe an"
  echo "  \$${0} --help"
  exit 0
}

################################################################################
#                                    Start                                     #
################################################################################
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ ${@} == "-" ]] || [[ ${@} == "--" ]]; then
        echo "Keine gueltige Option angegeben !!"
        echo -e " "
        help
        exit 2
    fi

    OPTS="$(getopt -o "hvV" --long "help,verbose,version" -n "${progname}" -- "${@}")"
    if [[ "${?}" != "0" ]] ; then
        echo "Fehler: Unbekannte Option ${1}" >&2
        exit 2
    fi
    eval set -- "$OPTS"

    while true; do
        case "${1}" in
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

if ! which ansible-vault > /dev/null 2>&1; then
  echo "ansible-vault command not found!"
  exit 1
fi

read -p 'Ansible variable: ' -r ansible_variable
read -p 'Encrypt string: ' -r encrypted_string
echo
ansible-vault encrypt_string "${encrypted_string}" --name "${ansible_variable}"
echo
echo
