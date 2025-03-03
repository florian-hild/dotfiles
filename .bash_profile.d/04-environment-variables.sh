# Set environment variables

export TERM=xterm-256color
export GPG_TTY=$(tty) # Needed to use gpg signed commits with git
export EDITOR=vim
declare -x -r DOT="$(dirname $(dirname "${BASH_SOURCE[0]}"))"
export BIN="$(dirname $(dirname "${BASH_SOURCE[0]}"))/bin"
export GIT="${HOME}/git"
export WORKSPACE="${HOME}/workspace"
