# bash-completion all the ssh commands from history

complete -W "$(/bin/grep -Pow "^ssh\s+([\.0-9a-zA-Z]+@)?([a-zA-Z]+([\.0-9a-zA-Z]+)?(-[\.0-9a-zA-Z]+)*|([0-9]{1,3}\.){3}[0-9]{1,3})" ${HISTFILE} | LANG=C sort | uniq)" ssh