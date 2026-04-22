#!/bin/sh

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Description: Show "ssh <host>" when an ssh client is running inside the pane,
#              otherwise "user@host". Root user is shown bold red.
#              Argument: tmux pane_pid
#
# Designed to minimise forks: a single ps + awk handles the tree walk
# and ssh-arg parsing entirely in awk.
#-------------------------------------------------------------------------------

PANE_PID=$1

ssh_target=$(
    [ -n "$PANE_PID" ] && ps -A -o pid=,ppid=,comm=,args= 2>/dev/null | awk -v root="$PANE_PID" '
    {
        pid  = $1
        ppid = $2
        comm = $3
        # Rebuild args (everything from field 4 onwards)
        args = ""
        for (i = 4; i <= NF; i++) args = args (i > 4 ? " " : "") $i

        children[ppid] = children[ppid] " " pid
        cmd[pid]  = comm
        argv[pid] = args
    }
    END {
        # BFS over descendants of root
        queue = root
        while (queue != "") {
            # pop first
            sub(/^ +/, "", queue)
            sp = index(queue, " ")
            if (sp) { p = substr(queue, 1, sp - 1); queue = substr(queue, sp + 1) }
            else    { p = queue; queue = "" }

            base = cmd[p]; sub(/.*\//, "", base)
            if (base == "ssh") {
                # parse args: skip "ssh" and option flags, take first positional
                n = split(argv[p], a, /[ \t]+/)
                target = ""
                i = 2  # skip program name
                while (i <= n) {
                    tok = a[i]
                    if (tok ~ /^-[bcDEeFIiJLlmOoPpQRSWw]$/) { i += 2; continue }
                    if (tok ~ /^-/) { i++; continue }
                    target = tok; break
                }
                sub(/.*@/, "", target)
                sub(/\..*/, "", target)
                print target
                exit
            }
            queue = queue children[p]
        }
    }'
)

if [ -n "$ssh_target" ]; then
    printf '%s' "$ssh_target"
elif [ "$(id -u)" -eq 0 ]; then
    printf '#[fg=colour160,bold]%s#[default]@%s' "$USER" "$(hostname -s)"
else
    printf '%s@%s' "$USER" "$(hostname -s)"
fi




