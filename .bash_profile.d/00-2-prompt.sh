# Custom prompt

# Git-aware prompt
__custom_git_ps1() {
    local gitdir branch status staged unstaged untracked stash_count

    gitdir=$(git rev-parse --git-dir 2>/dev/null) || return
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return

    status=$(git status --porcelain 2>/dev/null)

    # Count staged, unstaged, and untracked changes
    staged=$(echo "$status" | grep -E '^[A-Z]' | wc -l)
    unstaged=$(echo "$status" | grep -E '^.[^ ]' | wc -l)
    untracked=$(echo "$status" | grep -E '^\?\?' | wc -l)

    # Stash count
    stash_count=0
    [[ -e "$gitdir/logs/refs/stash" ]] && stash_count=$(git stash list | wc -l)

    local symbols=""
    [[ $staged -gt 0 ]] && symbols+="+"
    [[ $unstaged -gt 0 ]] && symbols+="*"
    [[ $untracked -gt 0 ]] && symbols+="?"
    [[ $stash_count -gt 0 ]] && symbols+="!"

    echo "[${branch}${symbols}]"
}

__custom_awscli_ps1() {
    if [[ -n "${AWS_PROFILE// }" ]]; then
      echo "(${AWS_PROFILE})"
    fi
}

# Prompt
if [[ "${TERM}" =~ ^(screen|xterm|tmux-).*$ ]]; then
    # Color definitions
    ps1_color_user="\[$(tput setaf 85)\]"
    ps1_color_root="\[$(tput setaf 1)\]"
    ps1_color_git="\[$(tput setaf 3)\]"
    ps1_color_aws="\[$(tput setaf 10)\]"
    ps1_color_wd="\[$(tput setaf 81)\]"
    ps1_colort_reset="\[$(tput sgr0)\]"

    if [[ "$(id -u)" -eq 0 ]]; then
        PS1="${ps1_color_root}\u@\h${ps1_color_git}\$(__custom_git_ps1)${ps1_color_aws}\$(__custom_awscli_ps1)${ps1_colort_reset}: ${ps1_color_wd}\w\n${ps1_color_root}\$ ${ps1_colort_reset}"
    else
        PS1="${ps1_color_user}\u@\h${ps1_color_git}\$(__custom_git_ps1)${ps1_color_aws}\$(__custom_awscli_ps1)${ps1_colort_reset}: ${ps1_color_wd}\w\n${ps1_color_user}\$ ${ps1_colort_reset}"
    fi
    unset ps1_color_user ps1_color_root ps1_color_git ps1_color_aws ps1_color_wd ps1_colort_reset
fi
