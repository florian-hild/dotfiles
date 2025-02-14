# Docker

if command -v docker > /dev/null 2>&1; then
  alias dps='docker ps --all --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'
  alias dimages='docker images --tree'
  alias dshell='docker exec --interactive --tty'
  alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
fi

if command -v podman > /dev/null 2>&1; then
  if ! command -v docker > /dev/null 2>&1; then
    alias docker='podman'
  fi
  alias dps='podman ps --all --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'
  alias dimages='podman images --sort repository'
  alias dshell='podman exec --interactive --tty'
fi
