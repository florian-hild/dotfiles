#!/usr/bin/env bash
#
# check_printer_status.sh
# Checks reachability of printer queues configured in CUPS and
# produces a report suitable for hand-off.
#
# Usage:
#   ./check_printer_status.sh                              check all queues
#   ./check_printer_status.sh -q Office_HL2350,Lab_Color   check only these queues
#   ./check_printer_status.sh -p                           only queues that need attention
#   ./check_printer_status.sh -q a,b -p --csv out.csv      combined
#
# Exit code: 0 = everything fine, 1 = at least one queue needs attention
#
if [ -z "${BASH_VERSINFO:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "${0##*/}: needs bash 4 or newer (found: ${BASH_VERSION:-not bash})." >&2
    echo "Run it as 'bash ${0##*/}', not 'sh ${0##*/}'. On macOS: brew install bash." >&2
    exit 2
fi

set -uo pipefail

TIMEOUT="${TIMEOUT:-3}"
CSVFILE=""
TXTFILE=""
PROBLEMS_ONLY=0
PROGRESS=1
[ -t 2 ] || PROGRESS=0     # no progress noise when stderr is redirected
declare -a WANT=()          # requested queue names, lower case
declare -a WANT_ORIG=()     # requested queue names as typed
declare -A SEEN=()          # which requested names actually exist in CUPS

usage() {
    cat << EOF
Usage: ${0##*/} [options]

  -q, --queues LIST     comma separated queue names to check (default: all)
                        may be given more than once; matching ignores case
  -p, --problems-only   list only queues that are unreachable or disabled
  -o, --out FILE        also write the report to FILE as plain text
      --csv FILE        also write the result to FILE (semicolon separated)
  -t, --timeout SEC     connection timeout per port (default: 3)
      --quiet           suppress the progress output on stderr
  -l, --list            list configured queue names and exit
  -h, --help            show this help

Examples:
  ${0##*/} -q Office_HL2350,Lab_Color
  ${0##*/} -p --csv printer-status.csv
  ${0##*/} -o report.txt
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        -q|--queues)
            IFS=',' read -ra _parts <<< "${2:-}"
            for _p in ${_parts[@]+"${_parts[@]}"}; do
                _p="${_p#"${_p%%[![:space:]]*}"}"      # trim leading space
                _p="${_p%"${_p##*[![:space:]]}"}"      # trim trailing space
                [ -z "$_p" ] && continue
                WANT+=("${_p,,}")
                WANT_ORIG+=("$_p")
            done
            shift 2 ;;
        -p|--problems-only) PROBLEMS_ONLY=1; shift ;;
        -o|--out)           TXTFILE="${2:-printer-status.txt}"; shift 2 ;;
        --csv)              CSVFILE="${2:-printer-status.csv}"; shift 2 ;;
        -t|--timeout)       TIMEOUT="${2:-3}"; shift 2 ;;
        --quiet)            PROGRESS=0; shift ;;
        -l|--list)          LC_ALL=C lpstat -v 2>/dev/null | sed 's/^device for //; s/:.*//'; exit 0 ;;
        -h|--help)          usage; exit 0 ;;
        *)                  echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

# fail fast: better to abort now than after probing every queue
for _f in "$TXTFILE" "$CSVFILE"; do
    [ -z "$_f" ] && continue
    if ! : > "$_f" 2>/dev/null; then
        echo "${0##*/}: cannot write to $_f" >&2
        exit 2
    fi
done

# ------------------------------------------------------------- helpers
# should this queue be checked?
want_queue() {
    [ "${#WANT[@]}" -eq 0 ] && return 0
    local q="${1,,}" w
    for w in ${WANT[@]+"${WANT[@]}"}; do
        [ "$q" = "$w" ] && return 0
    done
    return 1
}

# prefers nc, falls back to bash /dev/tcp
port_open() {
    local host="$1" port="$2"
    if command -v nc > /dev/null 2>&1; then
        timeout "$((TIMEOUT + 2))" nc -z -w "$TIMEOUT" "$host" "$port" > /dev/null 2>&1
    else
        timeout "$TIMEOUT" bash -c "exec 3<>/dev/tcp/$host/$port" > /dev/null 2>&1
    fi
}

# ------------------------------------------------------------- collect data
declare -a ROWS=()
SEP=$'\x1f'                 # unit separator: safe field delimiter for read
configured=0; total=0; failed=0; disabled=0; local_dev=0; net_checked=0

while read -r _ _ queue uri; do
    queue="${queue%:}"
    [ -z "$queue" ] && continue
    configured=$((configured + 1))

    want_queue "$queue" || continue
    SEEN["${queue,,}"]=1
    total=$((total + 1))

    scheme="${uri%%:*}"
    rest="${uri#*://}"
    hostport="${rest%%/*}"
    hostport="${hostport##*@}"          # strip user:pass@

    case "$hostport" in
        \[*\]*)                          # bracketed IPv6
            host="${hostport%%]*}"; host="${host#[}"
            port="${hostport##*]}"; port="${port#:}"
            ;;
        *:*) host="${hostport%%:*}"; port="${hostport##*:}" ;;
        *)   host="$hostport"; port="" ;;
    esac

    if [ -z "$port" ]; then
        case "$scheme" in
            socket)   port=9100 ;;
            ipp|http) port=631  ;;
            ipps)     port=631  ;;
            https)    port=443  ;;
            lpd)      port=515  ;;
            smb)      port=445  ;;
        esac
    fi

    # queue state and pending jobs (LC_ALL=C keeps the keywords stable)
    line="$(LC_ALL=C lpstat -p "$queue" 2>/dev/null | head -1)"
    case "$line" in
        *disabled*) qstate="disabled" ;;
        *printing*) qstate="printing" ;;
        *idle*)     qstate="idle" ;;
        *)          qstate="unknown" ;;
    esac
    jobs="$(LC_ALL=C lpstat -o "$queue" 2>/dev/null | grep -c .)"

    issue=""
    [ "$PROGRESS" -eq 1 ] && printf '  checking %-24s ... ' "$queue" >&2

    case "$scheme" in
        usb|parallel|serial|file|cups-brf|hp|hpfax)
            host="(local)"; port="-"; link="n/a"
            local_dev=$((local_dev + 1))
            ;;
        dnssd|implicitclass|ipp14)
            host="${host:-(dnssd)}"; port="${port:--}"; link="unchecked"
            ;;
        *)
            if [ -z "$host" ] || [ -z "$port" ]; then
                link="unchecked"
            elif net_checked=$((net_checked + 1)); port_open "$host" "$port"; then
                link="OK"
            else
                link="FAILED"
                failed=$((failed + 1))
                issue="no TCP connection to $host:$port"
            fi
            ;;
    esac

    [ "$PROGRESS" -eq 1 ] && printf '%s\n' "$link" >&2

    if [ "$qstate" = "disabled" ]; then
        disabled=$((disabled + 1))
        issue="${issue:+$issue, }queue is disabled"
    fi
    if [ "$jobs" -gt 0 ] && [ "$link" = "FAILED" ]; then
        issue="${issue:+$issue, }$jobs job(s) waiting"
    fi

    ROWS+=("${queue}${SEP}${host}${SEP}${port}${SEP}${link}${SEP}${qstate}${SEP}${jobs}${SEP}${issue}${SEP}${uri}")
done < <(LC_ALL=C lpstat -v 2>/dev/null)

[ "$PROGRESS" -eq 1 ] && echo >&2

# ------------------------------------------------------------- sanity checks
if [ "$configured" -eq 0 ]; then
    echo "No print queues found (is cupsd running?)." >&2
    exit 1
fi

declare -a MISSING=()
for i in ${WANT[@]+"${!WANT[@]}"}; do
    [ -n "${SEEN[${WANT[$i]}]:-}" ] || MISSING+=("${WANT_ORIG[$i]}")
done

if [ "${#WANT[@]}" -gt 0 ] && [ "$total" -eq 0 ]; then
    echo "None of the requested queues exist in CUPS: ${MISSING[*]}" >&2
    echo "Configured queues are:" >&2
    LC_ALL=C lpstat -v 2>/dev/null | sed 's/^device for /  /; s/:.*//' >&2
    exit 1
fi

# ------------------------------------------------------------- report
problem_count=${#MISSING[@]}
for row in ${ROWS[@]+"${ROWS[@]}"}; do
    IFS="$SEP" read -r _ _ _ _ _ _ issue _ <<< "$row"
    [ -n "$issue" ] && problem_count=$((problem_count + 1))
done

# CSV header up front, so the file exists even when there is nothing to report
[ -n "$CSVFILE" ] && printf 'Queue;Host;Port;Link;Queue state;Pending jobs;Issue;URI\n' > "$CSVFILE"

# Plausibility note: if every single probe failed, suspect the probe, not the printers
selftest_note() {
    local method loopback
    if command -v nc > /dev/null 2>&1; then
        method="nc -z -w $TIMEOUT HOST PORT ($(nc -h 2>&1 | head -1 | cut -c1-40))"
    else
        method="bash /dev/tcp fallback (nc not installed)"
    fi
    if port_open 127.0.0.1 631; then loopback="OK"; else loopback="FAILED"; fi

    echo "NOTE  All $net_checked checked queue(s) failed. That pattern usually points at the"
    echo "      check itself rather than at $net_checked broken printers:"
    echo "        probe method     : $method"
    echo "        localhost:631    : $loopback"
    if [ "$loopback" = "FAILED" ]; then
        echo "        -> cupsd's own port is unreachable too, so the probe method is at fault"
        echo "           (nc without -z support, or outbound TCP blocked on this host)"
    else
        echo "        -> the probe works locally, so suspect DNS or a firewall towards the"
        echo "           printer network"
    fi
    echo "      Verify one printer by hand:"
    echo "        getent hosts <host>        # does the name resolve at all?"
    echo "        nc -zv <host> 9100         # what does the probe say without -q?"
    echo "      Short host names need matching search domains in /etc/resolv.conf."
    echo
}

render_report() {
    if [ "$PROBLEMS_ONLY" -eq 1 ]; then
        echo "Printer reachability - issues only"
    else
        echo "Printer reachability"
    fi
    echo "Generated : $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "Checked by: $(hostname) (timeout ${TIMEOUT}s per connection)"
    if [ "${#WANT[@]}" -gt 0 ]; then
        echo "Scope     : $total of $configured configured queue(s), selected by name"
    else
        echo "Scope     : all $configured configured queue(s)"
    fi
    echo

    if [ "$PROBLEMS_ONLY" -eq 1 ] && [ "$problem_count" -eq 0 ]; then
        echo "All $total checked queue(s) OK - nothing to report."
        return 0
    fi

    [ "$net_checked" -gt 1 ] && [ "$failed" -eq "$net_checked" ] && selftest_note

    local fmt="%-24s %-22s %-5s %-9s %-11s %4s  %s\n"
    # shellcheck disable=SC2059
    printf "$fmt" "QUEUE" "HOST/IP" "PORT" "LINK" "QUEUE" "JOBS" "ISSUE"
    printf '%s\n' "---------------------------------------------------------------------------------------"

    local row queue host port link qstate jobs issue uri m
    for row in ${ROWS[@]+"${ROWS[@]}"}; do
        IFS="$SEP" read -r queue host port link qstate jobs issue uri <<< "$row"
        if [ "$PROBLEMS_ONLY" -eq 1 ] && [ -z "$issue" ]; then
            continue
        fi
        # shellcheck disable=SC2059
        printf "$fmt" "$queue" "$host" "$port" "$link" "$qstate" "$jobs" "${issue:--}"
        if [ -n "$CSVFILE" ]; then
            printf '"%s";"%s";"%s";"%s";"%s";"%s";"%s";"%s"\n' \
                "$queue" "$host" "$port" "$link" "$qstate" "$jobs" "$issue" "$uri" >> "$CSVFILE"
        fi
    done

    for m in ${MISSING[@]+"${MISSING[@]}"}; do
        # shellcheck disable=SC2059
        printf "$fmt" "$m" "-" "-" "-" "not found" "-" "requested but not configured in CUPS"
        if [ -n "$CSVFILE" ]; then
            printf '"%s";"";"";"";"not found";"";"requested but not configured in CUPS";""\n' \
                "$m" >> "$CSVFILE"
        fi
    done

    echo
    echo "Summary: $total queue(s) checked, $failed unreachable, $disabled disabled, $local_dev locally attached."
    [ "${#MISSING[@]}" -gt 0 ] && echo "         ${#MISSING[@]} requested queue(s) do not exist: ${MISSING[*]}"
    echo
    echo "Legend"
    echo "  OK          TCP port answers, printer is reachable on the network"
    echo "  FAILED      no TCP connection - device off, asleep, or stale IP address"
    echo "  unchecked   address is resolved at print time only (e.g. dnssd)"
    echo "  n/a         locally attached via USB/parallel, no network check"
    echo "  not found   queue name was requested but is not configured on this host"
    return 0
}

if [ -n "$TXTFILE" ]; then
    if ! render_report | tee "$TXTFILE"; then
        echo "Could not write report to $TXTFILE" >&2
        exit 1
    fi
    echo
    echo "Report written: $TXTFILE"
else
    render_report
fi

[ -n "$CSVFILE" ] && echo && echo "CSV written: $CSVFILE"

[ "$problem_count" -gt 0 ] && exit 1
exit 0
