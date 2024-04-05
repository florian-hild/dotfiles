# bashrc from F.Hild

# Add to ~/.bashrc:
# if [ -f ${HOME}/linux_home*/.bashrc ]; then
#   . ${HOME}/linux_home*/.bashrc
# fi

 if [ -f ${HOME}/.bash_profile ]; then
  echo "source .bash_profile from .bashrc"
  . ${HOME}/.bash_profile
fi

