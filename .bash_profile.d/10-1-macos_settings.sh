# macos settings

# Mac OS paths
if [[ "$(uname -s)" == "Darwin" ]]; then
  export BASH_SILENCE_DEPRECATION_WARNING=1
  export CLICOLOR=1
  export DOWNLOADS="${HOME}/Downloads"
  export DESKTOP="${HOME}/Desktop"
  export DOCUMENTS="${HOME}/Documents"
  export PICTURES="${HOME}/Pictures"

  # Load ITerm2 shell integration
  if [[ -r "${HOME}/.iterm2_shell_integration.bash" ]]; then
    source "${HOME}/.iterm2_shell_integration.bash"
  fi

  # Open JNLP files with OpenWebStart
  function open_jnlp() {
    local jnlp_file="${1}"

    if [[ -f "${jnlp_file}" ]]; then
      open -a "OpenWebStart javaws" "$jnlp_file"
    else
      echo "JNLP-File not found: ${jnlp_file}"
    fi
  }
fi
