# Set aliases

if [[ "$(uname)" == "Darwin" ]]; then
  alias ll="ls -lh --color"
  alias ls="ls -h --color"
else
  alias ll="ls -lh --color --time-style=long-iso"
  alias ls="ls -h --color --time-style=long-iso"
fi
alias grep="grep --color"
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias du="du -sh *"
alias df="df -hT"
alias tree="tree -C"
alias vi="vim"
if [[ "$(uname -s)" == "Darwin" ]]; then
  alias diff="diff --ignore-blank-lines --ignore-space-change --ignore-all-space"
else
  alias diff="diff --ignore-tab-expansion --ignore-trailing-space --ignore-blank-lines --ignore-space-change --ignore-all-space"
fi
alias less="less -R"
