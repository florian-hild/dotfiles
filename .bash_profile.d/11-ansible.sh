# Ansible

if [[ -n "${ANSIBLE// }" ]]; then
  export ANSIBLE_HOME="${HOME}/.ansible"
  export ANSIBLE_CONFIG="${ANSIBLE}/ansible.cfg"
  export ANSIBLE_FORCE_COLOR=True
  export INVENTORIES="${ANSIBLE}/environments"
  export CUST="${INVENTORIES}/customers"
  export INT="${INVENTORIES}/intern"
  export TEST="${INVENTORIES}/test"
  export PLAYBOOKS="${ANSIBLE}/playbooks"
  export ROLES="${ANSIBLE}/roles"
  export ROLESWIP="${ANSIBLE}/roles_wip"

  if [[ -n "${ANSIBLE_RUN_ENV// }" ]]; then
    if [[ "${ANSIBLE_RUN_ENV// }" == "container" ]]; then
      function ansible-container(){
        local ansible_args="${@}"
        docker run \
        --rm \
        --init \
        --volume ~/.ssh/${ANSIBLE_DEFAULT_SSH_KEY-"id_ed25519"}:/home/ansible/.ssh/${ANSIBLE_DEFAULT_SSH_KEY-"id_ed25519"}:ro \
        --volume ${ANSIBLE}:/home/ansible/ansible:ro \
        --volume ${ANSIBLE_HOME}:/home/ansible/.ansible:rw \
        --env VAULT_PASSWORD="${VAULT_PASSWORD}" \
        --env WORK_PATH="/home/ansible/ansible/${PWD#*ansible/}" \
        --name ansible-worker-$(date +'%Y%m%d_%H%M%S') \
        local/ansible:${ANSIBLE_DEFAULT_VERSION-"latest"}-alpine \
        bash -c "${ansible_args}"
      }

      function ansible-playbook(){
        local ansible_playbook_args="${@}"
        ansible-container "ansible-playbook \${WORK_PATH}/${ansible_playbook_args}"
      }

      function ansible-lint(){
        local lint_target=${1:-"/home/ansible/ansible/${PWD#*ansible/}/*"}
        local work_path_suffix=${PWD#*ansible/}

        echo "Lint target: ${lint_target}"
        echo "Work path suffix: ${work_path_suffix}"
        echo "Linting using yamllint..."
        docker run \
        --rm \
        --init \
        --volume ${ANSIBLE}:/home/ansible/ansible:ro \
        --env VAULT_PASSWORD="${VAULT_PASSWORD}" \
        --env LINT_CONFIG_FILE="/home/ansible/ansible/${work_path_suffix%%/*}/.yamllint" \
        --name ansible-worker-$(date +'%Y%m%d_%H%M%S') \
        local/ansible:${ANSIBLE_DEFAULT_VERSION:-"latest"}-alpine \
        bash -c "find ${lint_target} -type f \( -name '*.yaml' -o -name '*.yml' \) -exec yamllint -c \${LINT_CONFIG_FILE} {} +"

        echo "Linting using ansible-lint..."
        docker run \
        --rm \
        --init \
        --volume ${ANSIBLE}:/home/ansible/ansible:ro \
        --env VAULT_PASSWORD="${VAULT_PASSWORD}" \
        --env LINT_CONFIG_FILE="/home/ansible/ansible/${work_path_suffix%%/*}/.ansible-lint" \
        --name ansible-worker-$(date +'%Y%m%d_%H%M%S') \
        local/ansible:${ANSIBLE_DEFAULT_VERSION:-"latest"}-alpine \
        bash -c "ansible-lint --format brief --config-file \${LINT_CONFIG_FILE} ${lint_target}"
      }
    elif [[ "${ANSIBLE_RUN_ENV// }" == "venv" ]]; then
      if [[ -n "${ANSIBLE_RUN_VENV_PATH// }" ]]; then
        alias setansible="source ${ANSIBLE_RUN_VENV_PATH// }/bin/activate"
      else
        echo "Error: variable \$ANSIBLE_RUN_VENV_PATH not set."
      fi
    fi
  else
    echo "Error: variable \$ANSIBLE_RUN_ENV not set."
  fi
fi
