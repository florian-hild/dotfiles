# AWS cli setup

if [[ -f "${HOME}/.aws/login" ]]; then
  alias aws-login=". ${HOME}/.aws/login"
  alias aws-logout='aws sso logout && unset AWS_PROFILE'
  function aws-list { /usr/bin/grep profile ${HOME}/.aws/config | awk '{print $2}' | cut -d']' -f1 | LANG=C sort; }
fi
