# Set PATH

# UNIX
linux_paths=(
  "/usr/local/bin"
  "$(dirname $(dirname "${BASH_SOURCE[0]}"))/bin"
)

# Mac OS
if [[ "$(uname -s)" == "Darwin" ]]; then
  mac_paths=(
    "/usr/local/opt/gnu-getopt/bin"
    "/usr/local/opt/coreutils/bin"
  )
fi

# Local host
if [[ -n "${local_paths}" ]]; then
  # Merge linux_paths & mac_paths & local_paths
  all_paths=("${linux_paths[@]}" "${mac_paths[@]}" "${local_paths[@]}")
else
  # Merge linux_paths & mac_paths
  all_paths=("${linux_paths[@]}" "${mac_paths[@]}")
fi

# Export PATH
for lpath in "${all_paths[@]}"; do
  if [[ ! "${PATH}" =~ "${lpath}" ]] && [[ -d ${lpath} ]]; then
    [[ -n "${BASH_PROFILE_DEBUG}" ]] && print_debug_msg "${BASH_SOURCE[0]}" "Add to PATH ${lpath}"
    export PATH="${lpath}:${PATH}"
  fi
done

unset linux_paths
unset mac_paths
unset local_paths
unset all_paths
unset lpath
