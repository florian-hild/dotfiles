set_ssh_agent() {
  if pgrep -f ssh-agent; then
    export SSH_AUTH_SOCK=${HOME}/.ssh/ssh_auth_sock
    export SSH_AGENT_PID=$(pgrep ssh-agent)
  else
    rm -f ${HOME}/.ssh/ssh_auth_sock
    eval $(ssh-agent -a ${HOME}/.ssh/ssh_auth_sock)

    if [[ -r ${HOME}/.ssh/id_ed25519 ]]; then
      ssh-add ${HOME}/.ssh/id_ed25519
    elif [[ -r ${HOME}/.ssh/id_rsa ]]; then
      ssh-add ${HOME}/.ssh/id_rsa
    elif [[ -r ${HOME}/.ssh/ssh_key ]]; then
      ssh-add ${HOME}/.ssh/ssh_key
    else
      echo "ssh-agent: No SSH key found"
    fi
  fi
}

set_ssh_agent
