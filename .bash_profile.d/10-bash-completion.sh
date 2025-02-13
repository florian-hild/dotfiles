# bash-completion

# Add all ssh commands from history
[[ -n "${BASH_PROFILE_DEBUG}" ]] && print_debug_msg "${BASH_SOURCE[0]}" "Load bash completion from HISTFILE ssh commands"
complete -W "$(command grep -Eo "^ssh[[:space:]]+([\.0-9a-zA-Z]+@)?([a-zA-Z0-9.-]+)" "${HISTFILE}" | LANG=C sort | uniq)" ssh

# Mac OS
if [[ "$(uname -s)" == "Darwin" ]]; then
  [[ -n "${BASH_PROFILE_DEBUG}" ]] && print_debug_msg "${BASH_SOURCE[0]}" "Load bash completion from brew"
  export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
  [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi
