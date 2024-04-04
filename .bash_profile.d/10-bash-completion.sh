# bash-completion

# Add all ssh commands from history
if [[ "$(uname -s)" != "Darwin" ]]; then
  [[ -n "${BASH_PROFILE_DEBUG}" ]] && print_debug_msg "${BASH_SOURCE[0]}" "Load bash completion from HISTFILE ssh commands"
  complete -W "$($(which grep) -Pow "^ssh\s+([\.0-9a-zA-Z]+@)?([a-zA-Z]+([\.0-9a-zA-Z]+)?(-[\.0-9a-zA-Z]+)*|([0-9]{1,3}\.){3}[0-9]{1,3})" ${HISTFILE} | LANG=C sort | uniq)" ssh
fi

# Mac OS
if [[ "$(uname -s)" == "Darwin" ]]; then
  [[ -n "${BASH_PROFILE_DEBUG}" ]] && print_debug_msg "${BASH_SOURCE[0]}" "Load bash completion from brew"
  export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
  [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi
