# SUP
alias cvs_linux5="ssh -S none -R 2401:vmsupcis:2401 "
alias cvs_vmsupcis="ssh -S none -R 2401:vmsupcis:2401 "
alias cvs_linux7="ssh -S none -R 2401:linux7:2401 "
alias ssh_non_sock="ssh -S none "
alias checkdspport='echo "DSP PORT=${DISP_PORT}";ss -ltp "( sport = :${DISP_PORT} )"'
alias sendtestmail='uname -a|mail -s "Testmail" florian.hild@sup-logistik.de'
alias packageversion="rpm -qa|grep "
alias smbshares="smbclient -L \\\\localhost -N"
alias checkservices='systemctl list-units --type=service|grep -w -e "supcis" -e "firewalld" -e "smb" -e "tomcat" -e "oracle" -e "NetworkManager.service" -e "cups" -e "postfix"'
alias SQL="pwd=\$PWD; cd $HOME/linux_home_hild/sql_scripts; \$SQL && cd \$pwd"
alias SQLDBA="pwd=\$PWD; cd $HOME/linux_home_hild/sql_scripts; \$SQLDBA && cd \$pwd"
pssupcis() { ps -wwfo pid,user,group,%cpu,%mem,stat,atime,start,args --group supcis|grep -w -e PID -e /opt/supcis -e java|awk $'NR == 1; NR > 1 {print $0 | "sort -k 9"}'|less -S; }
pssupcist() { ps -wwfo pid,user,group,%cpu,%mem,stat,atime,start,args --group supcis|grep -w -e PID -e /opt/supcist -e java|awk $'NR == 1; NR > 1 {print $0 | "sort -k 9"}'|less -S; }
distribute() { ssh root@vmadmin "cd /usr/local/admin/distribute_user_key/ && ./distribute.pl $@"; }