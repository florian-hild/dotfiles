#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    :
# Description:
#------------------------------------------------------------------------------

export LANG=C
declare -r DOT_PATH="${HOME}/.dotfiles"

if ! grep -wq '.*/\.bashrc' ~/.bash_profile; then
echo "Add to ${HOME}/.bash_profile"
cat >> "${HOME}"/.bash_profile <<EOF

# Load .bashrc from ${HOME}
if [[ -f ${HOME}/.bashrc ]]; then
  . ${HOME}/.bashrc
fi

EOF
fi

if ! grep -wq 'dotfiles/\.bashrc' ~/.bashrc; then
echo "Add to ${HOME}/.bashrc"
cat >> "${HOME}"/.bashrc <<EOF

# Load .bashrc from ${DOT_PATH}
if [[ -f ${DOT_PATH}/.bashrc ]]; then
  . ${DOT_PATH}/.bashrc
fi

EOF
fi

if [[ ! -f ${HOME}/.gitconfig ]]; then
  echo "Create empty .gitconfig file"
  if [[ -h ${HOME}/.gitconfig ]]; then
    unlink "${HOME}"/.gitconfig
  fi

  touch "${HOME}"/.gitconfig
fi

if ! grep -wq 'dotfiles/\.gitconfig' ~/.gitconfig; then
echo "Add to ${HOME}/.gitconfig"
cat >> "${HOME}"/.gitconfig <<EOF

[include]
  path = ${DOT_PATH}/.gitconfig

EOF
fi

[[ ! -d "${HOME}/.terraform.d/plugin-cache" ]] && mkdir -p "${HOME}/.terraform.d/plugin-cache"


echo "Setup symlinks"
ln -sfn "${DOT_PATH}"/.vim "${HOME}"/.vim
ln -sfn "${DOT_PATH}"/.vimrc "${HOME}"/.vimrc
ln -sfn "${DOT_PATH}"/.digrc "${HOME}"/.digrc
ln -sfn "${DOT_PATH}"/.tmux.conf "${HOME}"/.tmux.conf
mkdir -p "${HOME}"/.tmux
ln -sfn "${DOT_PATH}"/.tmux/scripts "${HOME}"/.tmux/scripts
ln -sfn "${DOT_PATH}"/.terraformrc "${HOME}"/.terraformrc

[[ ! -d ${HOME}/bin ]] && ln -sn "${DOT_PATH}"/bin "${HOME}"/bin

# Herdr: link only the files that belong to the user. The app home also holds runtime
# state (shared.json, view.json, data/) and files the app rewrites on every start
# (AGENTS.md, *.d.ts, shipped layouts and mods), none of which belong in the repo.
HERDR_HOME="${HOME}/.config/herdr-app"
HERDR_SRC="${DOT_PATH}/.config/herdr-app"
if [[ -d ${HERDR_HOME} && -d ${HERDR_SRC} ]]; then
  echo "Setup herdr symlinks"
  for src in "${HERDR_SRC}"/*.json "${HERDR_SRC}"/layouts/*.json "${HERDR_SRC}"/mods/*; do
    [[ -e ${src} ]] || continue
    dest="${HERDR_HOME}/${src#"${HERDR_SRC}"/}"
    # ln -sfn would replace a real file, or put the link inside a real directory.
    if [[ -e ${dest} && ! -L ${dest} ]]; then
      echo "Skip ${dest}: exists and is not a symlink"
      continue
    fi
    mkdir -p "$(dirname "${dest}")"
    ln -sfn "${src}" "${dest}"
  done
fi

