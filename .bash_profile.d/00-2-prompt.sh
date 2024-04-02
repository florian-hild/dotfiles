# Custom prompt

if [[ "${TERM}" =~ ^(screen|xterm|tmux-).*$ ]]; then
  if [[ "${LOGNAME}" = "root" ]] || [[ "$(id -u)" -eq "0" ]]; then
    # Root prompt colors
    PS1='\[$(tput setaf 1)\]\u@\h\[$(tput setaf 3)\]$(git branch 2>/dev/null|sed -n "s/* \(.*\)/ [\1]/p")\[$(tput setaf 10)\]$([ -z ${AWS_PROFILE} ] || echo " (${AWS_PROFILE})")\[$(tput sgr0)\]: \[$(tput setaf 81)\]\w\n\[$(tput setaf 1)\]$\[$(tput sgr0)\] '
  else
    PS1='\[$(tput setaf 85)\]\u@\h\[$(tput setaf 3)\]$(git branch 2>/dev/null|sed -n "s/* \(.*\)/ [\1]/p")\[$(tput setaf 10)\]$([ -z ${AWS_PROFILE} ] || echo " (${AWS_PROFILE})")\[$(tput sgr0)\]: \[$(tput setaf 81)\]\w\n\[$(tput setaf 85)\]$\[$(tput sgr0)\] '
  fi
fi
