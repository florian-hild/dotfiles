# bash_profile
#
# Add to ~/.bash_profile:
# Load profile
# if [[ -f ~/linux_home/bash_profile ]]; then
#     . ~/linux_home/bash_profile
# fi

### Load extra bash profiles
# Load system specific bash profile
if [[ -f ~/.bash_profile_$(hostname -s) ]]; then
    . ~/.bash_profile_$(hostname -s)
fi

# Load all bash profile configs in .bash_profile.d directory
bash_config_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.bash_profile.d"
for bash_config_file in $(/usr/bin/find ${bash_config_path} -type f -name "*.sh" | LANG=C /usr/bin/sort); do
  . "${bash_config_file}"
done
unset bash_config_path
unset bash_config_file
