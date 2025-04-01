# homebrew

if command -v brew > /dev/null 2>&1; then
  # Aliases
  alias brewout='brew outdated'
  alias brewup='brew outdated && brew update && brew upgrade && brew cleanup'
fi
