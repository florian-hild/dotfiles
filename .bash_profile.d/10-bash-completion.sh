# bash-completion

bash_completion_paths=(
    /usr/share/bash-completion/bash_completion
    /usr/share/git/completion/git-completion.bash
)

for file in "${bash_completion_paths[@]}"; do
    if [[ -f "${file}" ]]; then
        source "${file}"
    fi
done
unset file
unset bash_completion_paths

tools=(
    docker
    podman
    buildah
    trivy
    dive
)

for cmd in "${tools[@]}"; do
    if command -v "${cmd// }" >/dev/null 2>&1; then
        source <("${cmd// }" completion bash 2>/dev/null)
    fi
done
unset cmd
unset tools

# OpenTofu completion
if command -v tofu >/dev/null 2>&1; then
    complete -C "$(which tofu)" tofu
fi

# macOS (Homebrew) Bash completion
if [[ "$(uname -s)" == "Darwin" ]]; then
    brew_prefix="$(brew --prefix)"
    export BASH_COMPLETION_COMPAT_DIR="${brew_prefix}/etc/bash_completion.d"

    if [[ -r "${brew_prefix}/etc/profile.d/bash_completion.sh" ]]; then
        source "${brew_prefix}/etc/profile.d/bash_completion.sh"
    else
        for completion in "${brew_prefix}/etc/bash_completion.d/"*; do
            [[ -r "${completion}" ]] && source "${completion}"
        done
        unset completion
    fi
fi

# SSH host completion from history
if [[ -n "${HISTFILE}" && -f "${HISTFILE}" ]]; then
    ssh_hosts=($(grep -Eo '^ssh\s+(([a-zA-Z0-9]+@)?[a-zA-Z0-9][a-zA-Z0-9\.-]*)' "${HISTFILE}" \
                 | awk '{print $2}' \
                 | LANG=C sort -u))
    [[ ${#ssh_hosts[@]} -gt 0 ]] && complete -W "${ssh_hosts[*]}" ssh
    unset ssh_hosts
fi
