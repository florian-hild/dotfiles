# Bash history

HISTSIZE= # unlimited
HISTFILESIZE= # unlimited
HISTTIMEFORMAT="|%Y-%m-%d %H:%M| "

# Store bash history immediately
PROMPT_COMMAND="history -a"
HISTCONTROL="ignoreboth"