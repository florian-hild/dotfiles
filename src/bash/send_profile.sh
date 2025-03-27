#!/bin/bash

if [[ "${#}" -gt 0 ]]; then
    hosts=("${@}")
else
    source "send_profile_hosts.lst"
fi

for host in "${hosts[@]}"; do
    rsync_cmd=(
        /opt/homebrew/bin/rsync
        --archive
        --compress
        --acls
        --hard-links
        --itemize-changes
        --inplace
        --delete
        --delete-during
        $(realpath ${HOME}/.dotfiles)/.
        hild@${host}:.dotfiles/
    )

    # Execute rsync command
    rsync_output=$("${rsync_cmd[@]}")
    files_synced=$(echo "${rsync_output}" | grep '^<' | wc -l)
    printf "Sync to ${host} (${files_synced// } changed)\n"
done
