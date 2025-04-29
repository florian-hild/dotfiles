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

  function list_jnlp() {
    ls -1tr "${DOWNLOADS}"/*.jnlp
  }

  # Open JNLP files with OpenWebStart
  function open_jnlp() {
    local jnlp_file="${1}"

    if [[ -z "${jnlp_file}" ]]; then
      jnlp_file="$(ls -1tr "${DOWNLOADS}"/*.jnlp 2>/dev/null | tail -n 1)"
    fi

    if [[ -f "${jnlp_file}" ]]; then
      echo "Opening JNLP-File: ${jnlp_file}"
      xattr -dr com.apple.quarantine "${jnlp_file}"
      open -a "OpenWebStart javaws" "${jnlp_file}"
    else
      echo "JNLP-File not found: ${jnlp_file}"
    fi
  }

  # Clear MS Teams cache with checks and logging
  function clear_ms_teams_cache() {
    local app_name="Microsoft Teams"
    local cache_paths=(
      "${HOME}/Library/Group Containers/UBF8T346G9.com.microsoft.teams"
      "${HOME}/Library/Containers/com.microsoft.teams2/Data"
    )


    echo "Stopping ${app_name}..."
    osascript -e "quit app \"${app_name}\""
    pkill -x "${app_name}"

    for path in "${cache_paths[@]}"; do
      if [ -d "${path}" ]; then
        echo "INFO Removing: ${path}"
        rm -rf "${path}"
      else
        echo "ERROR Path not found: ${path}"
      fi
    done

    echo "INFO ${app_name} cache clear process completed."

    echo "Starting ${app_name}..."
    open -a "${app_name}"
  }

fi
