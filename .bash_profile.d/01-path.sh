# shellcheck disable=SC2148
# Set PATH

function setPath() {
  local lpath="${1}"
  if [[ ":${PATH}:" != *":${lpath}:"* ]] && [[ -d ${lpath} ]]; then
    [[ -n "${BASH_PROFILE_DEBUG}" ]] && print_debug_msg "${BASH_SOURCE[0]}" "Add to PATH ${lpath}"
    export PATH="${lpath}:${PATH}"
  else
    [[ -n "${BASH_PROFILE_DEBUG}" ]] && print_debug_msg "${BASH_SOURCE[0]}" "Skip adding to PATH ${lpath}"
  fi

  if [[ ":${CUSTOM_PATH}:" != *":${lpath}:"* ]] && [[ -d ${lpath} ]]; then
    export CUSTOM_PATH="${lpath}:${CUSTOM_PATH}"
  fi
}

function reorderPath() {
  [[ -n "${BASH_PROFILE_DEBUG}" ]] && print_debug_msg "${BASH_SOURCE[0]}" "Run reorderPath()"

  local new_path=""
  declare -a seen_paths

  # Process CUSTOM_PATH first, then remaining PATH entries
  for dir in ${CUSTOM_PATH} ${PATH//:/ }; do
    if [[ -d "${dir}" ]] && [[ " ${seen_paths[*]} " != *" ${dir} "* ]]; then
      new_path+="${dir}:"
      seen_paths+=("${dir}")
    fi
  done

  export PATH="${new_path%:}"
}

# 1, collect paths
# 2. add to path or skip
# 3. reorder path


# Mac OS paths
if [[ "$(uname -s)" == "Darwin" ]]; then
  if ! command -v brew > /dev/null 2>&1; then
    echo "Checking for Homebrew installation..."
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
      brew_cmd="/opt/homebrew/bin/brew"
    elif [[ -x "/usr/local/bin/brew" ]]; then
      brew_cmd="/usr/local/bin/brew"
    else
      echo "[WARN] brew command not found"
      brew_cmd="brew"
    fi
  else
    brew_cmd="brew"
  fi

  setPath "$(${brew_cmd} --prefix)/opt/gnu-getopt/bin"
  setPath "$(${brew_cmd} --prefix)/opt/coreutils/libexec/gnubin"
  setPath "$(${brew_cmd} --prefix)/opt/make/libexec/gnubin"
  setPath "$(${brew_cmd} --prefix)/sbin"
  setPath "$(${brew_cmd} --prefix)/bin"

  unset brew_cmd
fi

# UNIX paths
setPath "/usr/local/bin"

# Local host paths
if [[ -n "${local_paths}" ]]; then
  for lpath in "${local_paths[@]}"; do
    setPath "${lpath}"
  done

  unset local_paths
fi

# .dotfiles/bin
setPath "$(dirname "$(dirname "${BASH_SOURCE[0]}")")/bin"

unset lpath
