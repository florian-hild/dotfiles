# git

# Git commit helpers (Conventional Commits)
gc() {
    local type="$1"; shift
    local scope=""
    local message=""

    # Validate type
    case "$type" in
        fix|feat|build|chore|docs|style|refactor|perf|test|ci|revert|init|delete) ;;
        *)
            echo "Unknown commit type: $type"
            return 1
            ;;
    esac

    # Optional scope: first argument in parentheses
    if [[ "$1" =~ ^\(.+\)$ ]]; then
        scope="$1"
        shift
    fi

    # Require commit message
    if [[ $# -eq 0 ]]; then
        echo "Error: commit message required"
        echo "Usage: gc <type> [(scope)] <message>"
        return 1
    fi

    # Join remaining arguments into message
    message="$*"

    # Empty commit support for init
    if [[ "$type" == "init" ]]; then
        git commit --allow-empty -m "${type}${scope}: ${message}"
    else
        git commit -m "${type}${scope}: ${message}"
    fi
}

# Bash completion for gc()
_gc_types=(fix feat build chore docs style refactor perf test ci revert init delete)
complete -W "${_gc_types[*]}" gc
