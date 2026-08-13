#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : 05-09-2022
# Description:
#------------------------------------------------------------------------------

export LANG=C

# help(exit_code)
# Print help message and exit
help() {
  local -r exit_code="${1:-0}"
  # Print help text
  cat << EOF
Encrypt string with ansible-vault

Usage:
  ${0} [options]

Options:
  -h, --help                     Display this help and exit
  -v, --verbose                  Print debugging messages

EOF
  exit "${exit_code}"
}

################################################################################
#                                    Start                                     #
################################################################################
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    while [[ $# -gt 0 ]]; do
        case "${1}" in
        -h | --help)
            help 0
            ;;
        -v | --verbose)
            set -xv  # Set xtrace and verbose mode.
            shift
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

    if [[ -n "${ANSIBLE// }" ]]; then
        # SC1091 - Added source=/dev/null directive for external source file
        # shellcheck source=/dev/null
        source "${DOT}"/.bash_profile.d/11-ansible.sh
    fi

    if ! command -v ansible-vault > /dev/null 2>&1; then
      echo "ansible-vault command not found!"
      exit 1
    fi

    read -p 'Ansible variable: ' -r ansible_variable
    read -p 'Encrypt string: ' -r encrypted_string
    echo
    ansible-vault encrypt_string "${encrypted_string}" --name "${ansible_variable}"
    echo
    echo
fi
