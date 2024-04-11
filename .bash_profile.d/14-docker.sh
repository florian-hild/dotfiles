# Docker

if command -v docker > /dev/null 2>&1; then
  alias dps='docker ps --all --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'
  alias dshell='docker exec --interactive --tty'
fi
