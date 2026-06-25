# shellcheck disable=SC2148
# Ansible

if [[ -n "${ANSIBLE_BASE// }" ]]; then
    # Core / version
    export ANSIBLE_VERSION="${ANSIBLE_VERSION:-"latest"}"
    export ANSIBLE_ENV="${ANSIBLE_ENV:-"latest"}"
    export ANSIBLE_HOME="${ANSIBLE_HOME:-"${ANSIBLE_BASE}/.config/${ANSIBLE_VERSION}"}"
    export ANSIBLE_VENV="${ANSIBLE_HOME}/venv"

    # Ansible configuration
    export ANSIBLE_CACHE_PLUGIN_CONNECTION="${ANSIBLE_BASE}/fact_cache"
    export ANSIBLE_COLLECTIONS_PATHS="${ANSIBLE_HOME}/collections"
    export ANSIBLE_CONFIG="${ANSIBLE_BASE}/ansible.cfg"
    export ANSIBLE_HOST_KEY_CHECKING="${ANSIBLE_HOST_KEY_CHECKING:-"True"}"
    export ANSIBLE_ROLES_PATH="${ANSIBLE_BASE}/roles_wip:${ANSIBLE_BASE}/roles"
    export ANSIBLE_VAULT_PASSWORD_FILE="${ANSIBLE_BASE}/.vault_pass.sh"

    # Inventories
    export INVENTORIES="${ANSIBLE_BASE}/environments"
    export CUST="${INVENTORIES}/customers"
    export INT="${INVENTORIES}/intern"
    export TEST="${INVENTORIES}/test"
    export ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-"${TEST}"}"

    # Playbooks and roles
    export PLAYBOOKS="${ANSIBLE_BASE}/playbooks"
    export ROLES="${ANSIBLE_BASE}/roles"
    export ROLESWIP="${ANSIBLE_BASE}/roles_wip"

    # PATH
    export PATH="${ANSIBLE_VENV}/bin:${PATH}"
fi
