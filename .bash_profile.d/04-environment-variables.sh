# Set environment variables

export TERM=xterm-256color
export GPG_TTY=$(tty) # Needed to use gpg signed commits with git
export EDITOR=vim
declare -x -r DOT="$(dirname $(dirname "${BASH_SOURCE[0]}"))"
export BIN="$(dirname $(dirname "${BASH_SOURCE[0]}"))/bin"export BIN="$(dirname $(dirname "${BASH_SOURCE[0]}"))"
export SQLPATH="~/linux_home_hild/sql_scripts:~/linux_home_hild/sql_scripts/asm:~/linux_home_hild/sql_scripts/dba:~/linux_home_hild/sql_scripts/sup:~/linux_home_hild/sql_scripts/tools:~/linux_home_hild/sql_scripts/user:${SQLPATH}"
