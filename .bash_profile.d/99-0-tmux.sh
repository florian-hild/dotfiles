# TMUX

# Start tmux if variable LOAD_TMUX is set and in login_shell
if [[ -n "${LOAD_TMUX// }" ]] && shopt -q login_shell; then
  if command -v tmux > /dev/null 2>&1; then
    # Check if inside a tmux session
    if [[ -z "${TMUX// }" ]]; then
      if [[ "${LOAD_TMUX// }" = "always-new-session" ]]; then
        # start a new session
        tmux -u new -s default-$(date +'%Y%m%d_%H%M%S') bash
      else
        # if no session is started, start a new session
        tmux -u new -A -s default bash
      fi
    fi
  else
    echo "Error: tmux command not found."
  fi
fi
