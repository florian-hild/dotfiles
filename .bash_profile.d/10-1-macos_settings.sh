# macos settings

# Mac OS paths
if [[ "$(uname -s)" == "Darwin" ]]; then
  export BASH_SILENCE_DEPRECATION_WARNING=1
  export CLICOLOR=1

  # Load ITerm2 shell integration
  if [[ -r "${HOME}/.iterm2_shell_integration.bash" ]]; then
    source "${HOME}/.iterm2_shell_integration.bash"
  fi
fi
