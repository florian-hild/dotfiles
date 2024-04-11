# SUP

alias cvs_linux5="ssh -S none -R 2401:vmsupcis:2401 "
alias cvs_vmsupcis="ssh -S none -R 2401:vmsupcis:2401 "
alias cvs_linux7="ssh -S none -R 2401:linux7:2401 "
alias checkdspport='echo "DSP PORT=${DISP_PORT}";ss -ltp "( sport = :${DISP_PORT} )"'
alias sendtestmail='uname -a|mail -s "Testmail" florian.hild@sup-logistik.de'
alias packageversion="rpm -qa|grep "
alias checkservices='systemctl list-units --type=service|grep -w -e "supcis" -e "firewalld" -e "smb" -e "tomcat" -e "oracle" -e "NetworkManager.service" -e "cups" -e "postfix"'
pssupcis() { ps -wwfo pid,user,group,%cpu,%mem,stat,atime,start,args --group supcis|grep -w -e PID -e /opt/supcis -e java|awk $'NR == 1; NR > 1 {print $0 | "sort -k 9"}'|less -S; }
pssupcist() { ps -wwfo pid,user,group,%cpu,%mem,stat,atime,start,args --group supcis|grep -w -e PID -e /opt/supcist -e java|awk $'NR == 1; NR > 1 {print $0 | "sort -k 9"}'|less -S; }
distribute() { ssh root@vmadmin "cd /usr/local/admin/distribute_user_key/ && ./distribute.pl $@"; }

# Oracle
export SQL_SCRIPTS="{HOME}/.dotfiles/oracle/sql"
export SQLPATH="${SQL_SCRIPTS}:${SQL_SCRIPTS}/asm:${SQL_SCRIPTS}/dba:${SQL_SCRIPTS}/sup:${SQL_SCRIPTS}/tools:${SQL_SCRIPTS}/user:${SQLPATH}"
alias SQL="pwd=\$PWD; cd ${SQL_SCRIPTS}; \$SQL && cd \$pwd"
alias SQLDBA="pwd=\$PWD; cd ${SQL_SCRIPTS}; \$SQLDBA && cd \$pwd"

# github cli
alias pr-mueller='gh pr create --reviewer bernd-mueller-1 --assignee florian-hild-1,bernd-mueller-1 --fill'
alias pr-scheub='gh pr create --reviewer Manuel-Scheub --assignee florian-hild-1,Manuel-Scheub --fill'
alias pr-woelk='gh pr create --reviewer fabian-woelk-1 --assignee florian-hild-1,fabian-woelk-1 --fill'
alias pr-seggelmann='gh pr create --reviewer robin-seggelmann --assignee florian-hild-1,robin-seggelmann --fill'
alias pr-ansible='gh pr create --reviewer bernd-mueller-1,Manuel-Scheub,fabian-woelk-1 --assignee florian-hild-1,bernd-mueller-1,Manuel-Scheub,fabian-woelk-1 --fill'
