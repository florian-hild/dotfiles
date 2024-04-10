# TMUX

# Start tmux if variable LOAD_TMUX is set and in login_shell
if [[ -n "${LOAD_TMUX// }" ]] && shopt -q login_shell; then
  if command -v tmux > /dev/null 2>&1; then
    # if not inside a tmux session, and if no session is started, start a new session
    test -z "${TMUX// }" && tmux -u new -A -s default bash
  else
    echo "Error: tmux command not found."
  fi
fi
