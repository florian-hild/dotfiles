#!/bin/bash

################################################################################
# Kurzbeschr. :
# Entwickler  : F.Hild
# Datum       : 22.11.21
# Ablageort   : bin
# Git-Repo    : linux_home_hild
# Beschreibung:
################################################################################

export LANG=C
declare -r VERSION='1.0'

# Prints program usage information.
show_usage() {
    echo -e "Verwendung: $(basename ${0}) [OPTIONEN]..."
    echo -e "  -d, --domain         Set Domain (Default: SAMBA)."
    echo -e "  -h, --help           Zeigt diese Hilfe."
    echo -e "  -p, --password       Set Password (Required)."
    echo -e "  -u, --user           Set Username (Required)."
    echo -e "  -v, --verbose        Debugging Ausgabe."
    echo -e "  -V, --version        Zeigt Skript Version."
    echo -e "  -s, --server         Set Server (Default: localhost)."
    echo -e "Aufrufbeispiele:"
    echo -e "  ./$(basename ${0}) -s 10.0.0.100 -u testdomain -p Geheim123"
    exit 0
}

test_smb_share(){
  echo " Username: ${username}"
  echo " Server:   ${server}"
  echo ""
  echo " Shares:"
  echo " -------------------------------------------------"

  cd "${TMPDIR:-/tmp}"
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
    if [[ ${#} -eq "0" ]] || [[ ${@} == "-" ]] || [[ ${@} == "--" ]]; then
        echo "Keine gueltige Option angegeben !!"
        echo -e " "
        show_usage
        exit 2
    fi

    OPTS="$(getopt -o "d:hp:u:vVs:" --long "domain:,help,password:,user:,verbose,version,server:" -n "${progname}" -- "${@}")"
    if [[ "${?}" != "0" ]] ; then
        echo "Fehler: Unbekannte Option ${1}" >&2
        exit 2
    fi
    eval set -- "$OPTS"

    while true; do
        case "${1}" in
        -d | --domain)
            declare domain="${2}"
            shift 2
            ;;
        -h | --help)
            show_usage
            exit 0
            ;;
        -p | --password)
            declare -r password="${2}"
            shift 2
            ;;
        -u | --user)
            declare username="${2}"
            shift 2
            ;;
        -v | --verbose)
            declare -r verbose="1"
            set -xv  # Set xtrace and verbose mode.
            shift
            ;;
        -V | --version)
            echo "${VERSION}"
            exit 0
            ;;
        -s | --server)
            declare server="${2}"
            shift 2
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

    if [[ -z "${username// }" ]] || [[ -z "${password// }" ]]; then
      echo "Parameter user oder password muss gesetzt sein!"
      exit 1
    fi

    server=${server:-"localhost"}
    username=${domain:-"SAMBA"}\\${username}

    test_smb_share

    exit
fi
