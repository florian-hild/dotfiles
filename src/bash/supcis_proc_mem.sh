#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : 10-06-2024
# Description: Process analyse script
#-------------------------------------------------------------------------------

export LANG=C
declare -r __SCRIPT_VERSION__='1.0'
declare -i main_opts_set=0

# help(exit_code)
# Print help message and exit
help() {
  local -r exit_code="${1:-0}"
  # Print help text
  cat << EOF
Usage:
  ${0} [options]

Options:
  -c, --cvs                       Print output as semicolon separated values
  -h, --help                      Display this help and exit
  --supcis-env <supcis_env>       Set supcis environment to use sc command (required for supcis proccesses)
  --supcis-proccesses <proc,proc> Set supcis processes to check
  --no-header                     Don't print csv header (useful for append to file)
  -p, --pids <pid,pid>            Set pids to check
  --timestamp                     Print timestamp (Always shown in CSV mode)
  -u, --user <username>           Set process user
  -v, --verbose                   Print debugging messages
  -V, --version                   Display version and exit

Examples:
  Get all processes
  \$ ${0}

  Get all processes for user oracle
  \$ ${0} -u oracle

  Get all supcis processes
  \$ ${0} --supcis-env sup

  Get processes as csv
  \$ ${0} --supcis-env supt --supcis-proccesses dsp,srv1,tms --csv > supt_procs.csv
EOF
  exit ${exit_code}
}

# set_supcis_environment()
# Source supcis environment
set_supcis_environment() {
  if [[ -r /usr/local/bin/supcis ]]; then
    . /usr/local/bin/supcis /opt/${supcis_env}/prod_v1/config/project.dat
  elif [[ -r /usr/bin/supenv ]]; then
    . /usr/bin/supenv ${supcis_env}
  else
    echo "Error: supcis environment \"${supcis_env}\" not found."
    exit 1
  fi
}

# get_process_info(mode, pids/user)
# Get process infos with ps command
# Modes: pid (can be comma seperated values), user, supcis or all
get_process_info() {
  local -r mode="${1}"
  local ps_cmd="/usr/bin/ps --no-headers -ww -o uname,pid,cputime,%cpu,%mem,rss,vsz,stat,args --sort=+rss"

  case "${mode}" in
    all)  ps_cmd+=" -e" ;;
    pid)  ps_cmd+=" --pid ${pids}" ;;
    user) ps_cmd+=" --user ${user}" ;;
    supcis)
      set_supcis_environment

      declare -A supcis_proc_map
      for name in ${supcis_processes}; do
        # Save supcis process name from sc in associative array using pid as key
        supcis_proc_map["$(sc csv ${name} | cut -d';' -f7)"]=${name}
      done

      # Extract keys (pids) from array and create comma seperated list
      local supcis_pids=$(printf -- '%s\n' "${!supcis_proc_map[@]}" | xargs -I % echo -n "%," | sed 's/,$//')

      ps_cmd+=" -p ${supcis_pids}"
      ;;
    *) echo "Error: Invalid mode: \"${mode}\"" && exit 1 ;;
  esac

  readarray -t ps_output < <(${ps_cmd})

  if [[ -z "${no_header// }" ]]; then
    # Print header
    if [[ -n "${csv// }" ]]; then
      # Only show header column if mode supcis
      if [[ "${mode}" == "supcis" ]]; then
        local -r SC_NAME_HEADER='SC_NAME;'
      fi
      echo "TIMESTAMP;${SC_NAME_HEADER}USER;PID;TIME;%CPU;%MEM;RSS;VSZ;STAT;COMMAND"
    else
      if [[ -n "${timestamp// }" ]]; then
        local -r timestamp_header='TIMESTAMP        '
      fi

      # Only show header column if mode supcis
      if [[ "${mode}" == "supcis" ]]; then
        local -r SC_NAME_HEADER='SC_NAME '
      fi
      echo "${timestamp_header}${SC_NAME_HEADER}USER         PID     TIME %CPU %MEM   RSS    VSZ STAT COMMAND"
      echo '------------------------------------------------------------------------------------------'
    fi

  fi

  if [[ -n "${csv// }" ]]; then
    # Print in CSV format
    for ps_line in "${ps_output[@]}"; do
      local username="$(echo "${ps_line}" | tr -s ' ' | cut -d' ' -f1)"
      local pid="$(echo "${ps_line}"      | tr -s ' ' | cut -d' ' -f2)"
      local time="$(echo "${ps_line}"     | tr -s ' ' | cut -d' ' -f3)"
      local cpu_pct="$(echo "${ps_line}"  | tr -s ' ' | cut -d' ' -f4)"
      local mem_pct="$(echo "${ps_line}"  | tr -s ' ' | cut -d' ' -f5)"
      local rss="$(echo "${ps_line}"      | tr -s ' ' | cut -d' ' -f6)"
      local vsz="$(echo "${ps_line}"      | tr -s ' ' | cut -d' ' -f7)"
      local stat="$(echo "${ps_line}"     | tr -s ' ' | cut -d' ' -f8)"
      local command="$(echo "${ps_line}"  | tr -s ' ' | cut -d' ' -f9-)"



      # Only show header column if mode supcis
      if [[ "${mode}" == "supcis" ]]; then
        printf "$(date +'%F %H-%M');%s;%s;%s;%s;%s;%s;%s;%s;%s;%s\n" "${supcis_proc_map[${pid}]}" "${username}" "${pid}" "${time}" "${cpu_pct}" "${mem_pct}" "${rss}" "${vsz}" "${stat}" "${command}"
      else
        printf "$(date +'%F %H-%M');%s;%s;%s;%s;%s;%s;%s;%s;%s\n" "${username}" "${pid}" "${time}" "${cpu_pct}" "${mem_pct}" "${rss}" "${vsz}" "${stat}" "${command}"
      fi
    done
  else
    # Print in human readable format
    if [[ -n "${timestamp// }" ]]; then
      local -r timestamp_value="$(date +'%F %H-%M') "
    fi

    for ps_line in "${ps_output[@]}"; do
      local pid="$(echo "${ps_line}"      | tr -s ' ' | cut -d' ' -f2)"
      local rss="$(echo "${ps_line}"      | tr -s ' ' | cut -d' ' -f6)"
      local proc_rss_total=$(expr ${proc_rss_total} + ${rss})

      # Only show header column if mode supcis
      if [[ "${mode}" == "supcis" ]]; then
        printf "${timestamp_value}%-7s %s\n" "${supcis_proc_map[${pid}]}" "${ps_line}"
      else
        printf "${timestamp_value}%s\n" "${ps_line}"
      fi
    done
    echo '=========================================================================================='
    echo "Total RSS: ${proc_rss_total} kB"
  fi

}

# main()
# Start of script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ ${#} -ne "0" ]]; then
    if [[ ${@} == "-" ]] || [[ ${@} == "--" ]]; then
      echo "Syntax or usage error (1)" >&2
      echo
      help 128
    fi

    OPTS="$(getopt -o 'chp:u:vV' --long 'csv,help,supcis-env:,supcis-proccesses:,no-header,pids:,timestamp,user:,verbose,version' -n "${0}" -- "${@}")"
    if [[ "${?}" != "0" ]] ; then
      echo "Syntax or usage error (2)" >&2
      echo
      help 128
    fi
    eval set -- "$OPTS"

    while true; do
      case "${1}" in
      -c | --csv)
        declare -r csv="1"
        shift
        ;;
      -h | --help)
        help 0
        ;;
      --supcis-env)
        declare -r supcis_env="${2}"
        shift 2
        ;;
      --supcis-proccesses)
        declare -r supcis_processes=$(echo ${2} | sed 's/,/ /g')
        shift 2
        ((main_opts_set++))
        ;;
      --no-header)
        declare -r no_header="1"
        shift
        ;;
      -p | --pids)
        declare -r pids="${2}"
        shift 2
        ((main_opts_set++))
        ;;
      --timestamp)
        declare -r timestamp="1"
        shift
        ;;
      -u | --user)
        declare -r user="${2}"
        shift 2
        ((main_opts_set++))
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
fi

if [[ -n "${supcis_env// }" ]] && [[ -z "${supcis_processes// }" ]]; then
  echo "Error: Option \"--supcis-proccesses\" not set."
  echo
  help 128
fi

if [[ -n "${supcis_processes// }" ]] && [[ -z "${supcis_env// }" ]]; then
  echo "Error: Option \"--supcis-env\" not set."
  echo
  help 128
fi

if [[ "${main_opts_set}" -eq 0 ]]; then
  get_process_info "all"
elif [[ "${main_opts_set}" -eq 1 ]]; then
  if [[ -n "${supcis_processes// }" ]]; then
    get_process_info "supcis"
  elif [[ -n "${pids// }" ]]; then
    get_process_info "pid" "${pids}"
  elif [[ -n "${user// }" ]]; then
    get_process_info "user" "${user}"
  else
    echo "Error: No option set."
    exit 1
  fi
else
  echo "Error: Only one of --supcis-processes, --pids, or --user can be set."
  echo
  help 128
fi

exit