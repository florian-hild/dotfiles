# Set PATH

function setPath() {
  local lpath=${1}
  if [[ ! "${PATH}" =~ "${lpath}" ]] && [[ -d ${lpath} ]]; then
    [[ -n "${BASH_PROFILE_DEBUG}" ]] && print_debug_msg "${BASH_SOURCE[0]}" "Add to PATH ${lpath}"
    export PATH="${lpath}:${PATH}"
  fi
}


# UNIX paths
linux_paths=(
  "/usr/local/bin"
)

if [[ -n "${linux_paths}" ]]; then
  for lpath in "${linux_paths[@]}"; do
    setPath "${lpath}"
  done

  unset linux_paths
fi


# Mac OS paths
if [[ "$(uname -s)" == "Darwin" ]]; then
  if ! command -v brew > /dev/null 2>&1; then
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
      brew_cmd="/opt/homebrew/bin/brew"
    elif [[ -x "/usr/local/bin/brew" ]]; then
      brew_cmd="/usr/local/bin/brew"
    else
      echo "[WARN] bre command not found"
      brew_cmd="brew"
    fi
  else
    brew_cmd="brew"
  fi

  mac_paths=(
    "$(${brew_cmd} --prefix)/opt/gnu-getopt/bin"
    "$(${brew_cmd} --prefix)/opt/coreutils/libexec/gnubin"
    "$(${brew_cmd} --prefix)/bin"
  )

  for lpath in "${mac_paths[@]}"; do
    setPath "${lpath}"
  done

  unset brew_cmd
  unset mac_paths
fi


# Local host paths
if [[ -n "${local_paths}" ]]; then
  for lpath in "${local_paths[@]}"; do
    setPath "${lpath}"
  done

  unset local_paths
fi

# .dotfiles/bin
setPath "$(dirname $(dirname "${BASH_SOURCE[0]}"))/bin"

unset lpath
