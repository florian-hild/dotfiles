# bash_profile from F.Hild

# Add to ~/.bash_profile:
# if [ -f ${HOME}/.dotfiles/bash_profile ]; then
#   . ${HOME}/.dotfiles/.bash_profile
# fi


#### Load extra bash profiles
# Load system specific bash profile
SECONDS=0
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
