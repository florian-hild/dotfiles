# bash-completion

# Add all ssh commands from history
complete -W "$(command grep -Eo "^ssh[[:space:]]+([\.0-9a-zA-Z]+@)?([a-zA-Z0-9.-]+)" "${HISTFILE}" | LANG=C sort | uniq)" ssh

# Mac OS Brew
if [[ "$(uname -s)" == "Darwin" ]]; then
  export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
  if [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]]; then
    source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
  else
    for completion in "$(brew --prefix)/etc/bash_completion.d/*"; do
      [[ -r "${completion}" ]] && source "${completion}"
    done
    unset completion
  fi
fi


# OpenTofu
if command -v tofu > /dev/null 2>&1; then
  complete -C "$(which tofu)" tofu
fi
