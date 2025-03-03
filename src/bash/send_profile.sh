#!/bin/bash

if [[ "${#}" -gt 0 ]]; then
    hosts=("${@}")
else
    source "send_profile_hosts.lst"
fi

for host in "${hosts[@]}"; do
    echo -n "Sync to ${host}"
    files_synced=$(rsync -azAHxi --delete --delete-during $(realpath ${HOME}/.dotfiles)/. hild@${host}:.dotfiles/ | /usr/bin/grep '^<' | /usr/bin/wc -l)
    echo -e " (${files_synced} changed)"
done
