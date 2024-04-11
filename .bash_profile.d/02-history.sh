# Bash history

HISTSIZE= # unlimited
HISTFILESIZE= # unlimited
HISTTIMEFORMAT="|%Y-%m-%d %H:%M| "

# Store bash history immediately
PROMPT_COMMAND="history -a"
HISTCONTROL="ignoreboth"

if [[ $(/bin/df --output=fstype . | sed 1d) =~ nfs ]]; then
  HISTFILE="${HOME}/.bash_history_$(hostname -s)"
fi
