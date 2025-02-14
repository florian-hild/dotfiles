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
alias diff="diff -EZBbw"
alias less="less -R"
