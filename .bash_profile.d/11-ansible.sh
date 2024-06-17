# Ansible

if [[ -n "${ANSIBLE// }" ]]; then
  export INVENTORIES="${ANSIBLE}/environments"
  export CUST="${INVENTORIES}/customers"
  export INT="${INVENTORIES}/intern"
  export TEST="${INVENTORIES}/test"
  export PLAYBOOKS="${ANSIBLE}/playbooks"
  export ROLES="${ANSIBLE}/roles"
  export ROLESWIP="${ANSIBLE}/roles_wip"

  alias setansible="source ${HOME}/project/python_venv/ansible/bin/activate"
  alias setansible8="source ${HOME}/project/python_venv/ansible-8/bin/activate"

  function ansible_test(){
    setansible
    yamllint -c .yamllint .
    ansible-lint -c .ansible-lint *
    # molecule test
  }
fi
