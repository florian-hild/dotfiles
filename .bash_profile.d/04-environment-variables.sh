# Set environment variables

export TERM=xterm-256color
export EDITOR=vim
export BIN="$(dirname $(dirname "${BASH_SOURCE[0]}"))/bin"
export SQLPATH="~/linux_home_hild/sql_scripts:~/linux_home_hild/sql_scripts/asm:~/linux_home_hild/sql_scripts/dba:~/linux_home_hild/sql_scripts/sup:~/linux_home_hild/sql_scripts/tools:~/linux_home_hild/sql_scripts/user:${SQLPATH}"
