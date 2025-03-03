# pyvenv

if [[ -d "${HOME}/.pyenv" ]]; then
  export PYENV_ROOT="${HOME}/.pyenv"
  [[ -d ${PYENV_ROOT}/bin ]] && setPath "${PYENV_ROOT}/bin"
  eval "$(pyenv init - bash)"
  eval "$(pyenv virtualenv-init - bash)"
fi
