# Docker

if command -v docker > /dev/null 2>&1; then
  alias dps='docker ps --all --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'
  alias dimages='docker images --tree'
  alias dshell='docker exec --interactive --tty'
  alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
fi
