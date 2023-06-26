#!/bin/bash

if ! grep -wq '\. ~/linux_home/\.bash_profile' ~/.bash_profile; then
cat <<EOT >> $HOME/.bash_profile

if [ -f $HOME/linux_home/.bash_profile ]; then
    . $HOME/linux_home/.bash_profile
fi
EOT
fi

ln -sfn $HOME/linux_home/.vim $HOME/.vim
ln -sfn $HOME/linux_home/.vimrc $HOME/.vimrc
ln -sfn $HOME/linux_home/.gitconfig $HOME/.gitconfig
ln -sfn $HOME/linux_home/.digrc $HOME/.digrc

