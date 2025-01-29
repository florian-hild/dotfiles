# pyvenv

if [[ -d "${HOME}/.pyenv" ]]; then
  export PYENV_ROOT="${HOME}/.pyenv"
  [[ -d ${PYENV_ROOT}/bin ]] && export PATH="${PYENV_ROOT}/bin:$PATH"
  eval "$(pyenv init - bash)"
  eval "$(pyenv virtualenv-init - bash)"
fi
