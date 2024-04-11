# bashrc from F.Hild

 # Not at non-interactiv shells
 if [[ $- == *i* ]]; then
  SECONDS=0 # Used to get execution time

  # Load host specific .bash_profile
  if [[ -f ~/.bash_profile_$(hostname -s) ]]; then
      . ~/.bash_profile_$(hostname -s)
  fi

  [[ -n "${BASH_PROFILE_TRACE}" ]] && set -x

  if [[ -n "${BASH_PROFILE_DEBUG}" ]]; then
    function print_debug_msg(){
      echo "$(date +'%H:%M:%S') [${1##*/}] ${2}"
    }
  fi

  # Load all bash profile configs in .bash_profile.d directory
  bash_config_path="$(dirname "${BASH_SOURCE[0]}")/.bash_profile.d"
  for bash_config_file in $(/usr/bin/find ${bash_config_path} -type f -name "*.sh" | LANG=C sort); do
    [[ -n "${BASH_PROFILE_DEBUG}" ]] && print_debug_msg "${BASH_SOURCE[0]}" "Load ${bash_config_file}"

    . "${bash_config_file}"
  done
  unset bash_config_path
  unset bash_config_file

  [[ -n "${BASH_PROFILE_DEBUG}" ]] && echo "$((${SECONDS} / 60)) minutes and $((${SECONDS} % 60)) seconds elapsed."
  unset SECONDS
  unset -f print_debug_msg
fi

