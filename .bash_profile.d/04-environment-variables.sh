# shellcheck disable=SC2148
# Set environment variables

export TERM=xterm-256color
GPG_TTY=$(tty) # Needed to use gpg signed commits with git
export GPG_TTY
export EDITOR=vim
DOT="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
declare -x DOT
BIN="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/bin"
export BIN
[[ -d ${HOME}/git ]] && export GIT="${HOME}/git"
[[ -d ${HOME}/workspace ]] && export WORKSPACE="${HOME}/workspace"
