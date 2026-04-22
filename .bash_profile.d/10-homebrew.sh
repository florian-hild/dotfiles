# homebrew

if command -v brew > /dev/null 2>&1; then
  # Aliases
  alias brewout='brew outdated'
  alias brewup='brew update && brew upgrade -g && brew cleanup --prune=7'
fi
