# Bash history

HISTSIZE= # unlimited
HISTFILESIZE= # unlimited
HISTTIMEFORMAT="|%Y-%m-%d %H:%M| "

# Store bash history immediately
PROMPT_COMMAND="history -a"
HISTCONTROL="ignoreboth"

if [[ $(stat -f -L -c %T ${HOME}) =~ nfs ]]; then
  HISTFILE="${HOME}/.bash_history_$(hostname -s)"
else
  HISTFILE="${HOME}/.bash_history"
fi

