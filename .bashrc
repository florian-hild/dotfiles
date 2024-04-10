# bashrc from F.Hild

# Add to ~/.bashrc:
# if [ -f ${HOME}/.dotfiles/.bashrc ]; then
#   . ${HOME}/.dotfiles/.bashrc
# fi

 # Not at non-interactiv shells
 if [[ $- == *i* ]] && [ -f ${HOME}/.bash_profile ]; then
  echo "source .bash_profile from .bashrc"
  . ${HOME}/.bash_profile
fi

