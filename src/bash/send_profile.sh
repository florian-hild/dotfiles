#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    :
# Description:
#------------------------------------------------------------------------------

export LANG=C

if [[ "${#}" -gt 0 ]]; then
    hosts=("${@}")
else
    # shellcheck source=/dev/null
    source "send_profile_hosts.lst"
fi

for host in "${hosts[@]}"; do
    dotfiles_path="$(realpath "${HOME}"/.dotfiles)"
    rsync_cmd=(
      rsync
        --archive
        --compress
        --hard-links
        --itemize-changes
        --inplace
        --delete
        --delete-during
        "${dotfiles_path}/."
        "hild@${host}:.dotfiles/"
    )

    # Execute rsync command
    rsync_output=$("${rsync_cmd[@]}")
    files_synced=$(echo "${rsync_output}" | grep -c '^<')
    printf 'Sync to %s (%s changed)\n' "${host}" "${files_synced// }"
done
