# Custom prompt

function __my_git_ps1() {
  local gitdir=$(git rev-parse --git-dir 2>/dev/null)
  if [[ -z "${gitdir// }" ]]; then
    return
  fi

  local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)
  if [[ -z "${branch// }" ]]; then
    return
  fi

  local status=""
  # Check for stashed changes
  if [[ -e "${gitdir}/logs/refs/stash" ]]; then
    status+="!"
  fi

  # Check for uncommitted changes
  if ! git diff --quiet --ignore-submodules --; then
      status+="*"
  fi

  # Check for staged but uncommitted files
  if ! git diff --cached --quiet --ignore-submodules --; then
      status+="+"
  fi

  echo "[${branch}${status}]"
}

if [[ "${TERM}" =~ ^(screen|xterm|tmux-).*$ ]]; then
  if [[ "${LOGNAME}" = "root" ]] || [[ "$(id -u)" -eq "0" ]]; then
    # Root prompt colors
    PS1='\[$(tput setaf 1)\]\u@\h\[$(tput setaf 3)\]$(__my_git_ps1)\[$(tput setaf 10)\]$([ -z ${AWS_PROFILE} ] || echo " (${AWS_PROFILE})")\[$(tput sgr0)\]: \[$(tput setaf 81)\]\w\n\[$(tput setaf 1)\]$\[$(tput sgr0)\] '
  else
    PS1='\[$(tput setaf 85)\]\u@\h\[$(tput setaf 3)\]$(__my_git_ps1)\[$(tput setaf 10)\]$([ -z ${AWS_PROFILE} ] || echo " (${AWS_PROFILE})")\[$(tput sgr0)\]: \[$(tput setaf 81)\]\w\n\[$(tput setaf 85)\]$\[$(tput sgr0)\] '
  fi
fi
