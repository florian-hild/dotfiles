#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : 05-09-2022
# Description: Encrypt a string with ansible-vault (secret is never shown on
#              screen or passed as a command line argument).
#------------------------------------------------------------------------------

export LANG=C
set -u -o pipefail

# help(exit_code)
# Print help message and exit
help() {
  local -r exit_code="${1:-0}"
  cat << EOF
Encrypt string with ansible-vault

Usage:
  ${0##*/} [options] [variable_name]

Options:
  -h, --help                     Display this help and exit
  -v, --verbose                  Print debugging messages

Arguments:
  variable_name                  Ansible variable name (prompted if omitted)

Examples:
  # Interactive: prompts for variable name and secret (hidden)
  ${0##*/}

  # Pass the variable name directly, only the secret is prompted
  ${0##*/} db_root_password

  # Result can be pasted directly into a vars file:
  db_root_password: !vault |
            \$ANSIBLE_VAULT;1.1;AES256
            6364636439333438...

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

    if ! command -v ansible-vault > /dev/null 2>&1 && [[ -n "${ANSIBLE_BASE:-}" && -n "${DOT:-}" ]]; then
        # SC1091 - Added source=/dev/null directive for external source file
        # shellcheck source=/dev/null
        source "${DOT}/.bash_profile.d/11-ansible.sh"
    fi

    if ! command -v ansible-vault > /dev/null 2>&1; then
        echo "Error: ansible-vault command not found!" >&2
        exit 1
    fi

    ansible_variable="${1:-}"
    if [[ -z "${ansible_variable}" ]]; then
        read -p 'Ansible variable: ' -r ansible_variable
    fi

    if [[ ! "${ansible_variable}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "Error: '${ansible_variable}' is not a valid Ansible variable name." >&2
        exit 2
    fi

    # Read secret without echoing it to the terminal
    read -p 'String to encrypt: ' -rs secret_string
    echo
    read -p 'Confirm: ' -rs secret_string_confirm
    echo

    if [[ "${secret_string}" != "${secret_string_confirm}" ]]; then
        echo "Error: Strings do not match." >&2
        exit 3
    fi

    if [[ -z "${secret_string}" ]]; then
        echo "Error: Empty string." >&2
        exit 4
    fi

    echo
    # --stdin-name: secret is passed via stdin, never visible in `ps` output
    printf '%s' "${secret_string}" | ansible-vault encrypt_string --stdin-name "${ansible_variable}"
    echo
fi
