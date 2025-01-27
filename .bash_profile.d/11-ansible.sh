# Ansible

if [[ -n "${ANSIBLE// }" ]]; then
  export INVENTORIES="${ANSIBLE}/environments"
  export CUST="${INVENTORIES}/customers"
  export INT="${INVENTORIES}/intern"
  export TEST="${INVENTORIES}/test"
  export PLAYBOOKS="${ANSIBLE}/playbooks"
  export ROLES="${ANSIBLE}/roles"
  export ROLESWIP="${ANSIBLE}/roles_wip"

function ansible(){
    local ansible_args="${@}"
    docker run \
    --rm \
    --init \
    --volume ~/.ssh/${ANSIBLE_DEFAULT_SSH_KEY-"id_ed25519"}:/home/ansible/.ssh/${ANSIBLE_DEFAULT_SSH_KEY-"id_ed25519"}:ro \
    --volume ~/project/ansible:/ansible:ro \
    --env VAULT_PASSWORD="${VAULT_PASSWORD}" \
    --name ansible-worker-$(date +'%Y%m%d_%H%M%S') \
    local/ansible:${ANSIBLE_DEFAULT_VERSION-"latest"}-alpine \
    bash -c "ansible ${ansible_args}"
}

function ansible-playbook(){
    local ansible_playbook_args="${@}"
    docker run \
    --rm \
    --init \
    --volume ~/.ssh/${ANSIBLE_DEFAULT_SSH_KEY-"id_ed25519"}:/home/ansible/.ssh/${ANSIBLE_DEFAULT_SSH_KEY-"id_ed25519"}:ro \
    --volume ~/project/ansible:/ansible:ro \
    --env VAULT_PASSWORD="${VAULT_PASSWORD}" \
    --env WORK_PATH="/ansible/${PWD#*ansible/}" \
    --name ansible-worker-$(date +'%Y%m%d_%H%M%S') \
    local/ansible:${ANSIBLE_DEFAULT_VERSION-"latest"}-alpine \
    bash -c "ansible-playbook \${WORK_PATH}/${ansible_playbook_args}"
}

function ansible-lint(){
    local lint_target=${1:-"/ansible/${PWD#*ansible/}/*"}
    local work_path_suffix=${PWD#*ansible/}

    echo "Lint target: ${lint_target}"
    echo "Work path suffix: ${work_path_suffix}"
    echo "Linting using yamllint..."
    docker run \
      --rm \
      --init \
      --volume ~/project/ansible:/ansible:ro \
      --env VAULT_PASSWORD="${VAULT_PASSWORD}" \
      --env LINT_CONFIG_FILE="/ansible/${work_path_suffix%%/*}/.yamllint" \
      --name ansible-worker-$(date +'%Y%m%d_%H%M%S') \
      local/ansible:${ANSIBLE_DEFAULT_VERSION:-"latest"}-alpine \
      bash -c "find ${lint_target} -type f \( -name '*.yaml' -o -name '*.yml' \) -exec yamllint -c \${LINT_CONFIG_FILE} {} +"

    echo "Linting using ansible-lint..."
    docker run \
      --rm \
      --init \
      --volume ~/project/ansible:/ansible:ro \
      --env VAULT_PASSWORD="${VAULT_PASSWORD}" \
      --env LINT_CONFIG_FILE="/ansible/${work_path_suffix%%/*}/.ansible-lint" \
      --name ansible-worker-$(date +'%Y%m%d_%H%M%S') \
      local/ansible:${ANSIBLE_DEFAULT_VERSION:-"latest"}-alpine \
      bash -c "ansible-lint --format brief --config-file \${LINT_CONFIG_FILE} ${lint_target}"
}
fi
