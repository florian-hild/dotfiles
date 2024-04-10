# My aliases
alias showaliases="alias|cut -d'=' -f1"
alias lstoday="ls -al --time-style=+%D | grep --color=none $(date +%D)"
alias findname="find -print -iname "
alias findbigfiles="find . -type f -exec du -Sh {} + | sort -rh | head -n 20"
alias find100+="find . -type f -size +100M -exec ls -lh {} + | sort -rh"
alias pscpu="ps -eo pid,user,group,%cpu,%mem,rss,atime,tty8,stat,args --sort=-pcpu | head -n 10"
alias psram="ps -eo pid,user,group,%cpu,%mem,rss,atime,tty8,stat,args --sort=-rss | head -n 10"
alias meminfo='free -hlt'
alias psme="ps -eo pid,user,group,%cpu,%mem,rss,atime,tty8,stat,args --sort=user|less -S"
function findhost { grep -i "$1" ~/.ssh/config --color; }
function mygrep { grep -rnIi "$1" . --color; }
alias pingf="ping -c4 -i0.3 -W0.1 -w2"
alias ports="ss -tulpn"
function historyf { history|grep -in "$1" --color; }
alias myhelp='echo lstoday; echo "findname <word>"; echo "pscpu"; echo "psram"; echo "psme"; echo "findhost <word>"; echo "mygrep <word>"; echo "pingf <host>"; echo "historyf <word>";'
function activate { if [[ -z "${1// }" ]]; then source $PWD/.venv/bin/activate; else source ~/project/python_venv/${1}/bin/activate; fi; }

# Docker:
alias dps='docker ps --all --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'
alias dshell='docker exec --interactive --tty'
