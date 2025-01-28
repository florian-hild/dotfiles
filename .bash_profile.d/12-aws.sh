# AWS cli setup

if command -v aws > /dev/null 2>&1; then
#   function aws-login(){
#       docker run --rm \
#                  -it \
#                  --init \
#                  --volume ~/.aws:/root/.aws \
#                  --env AWS_PROFILE=${1} \
#                  --env AWS_CONFIG_FILE=/root/.aws/config \
#                  --env AWS_SSO_SESSION=pm_local_session \
#                  --name aws-cli-worker-$(date +'%Y%m%d_%H%M%S') \
#                  public.ecr.aws/aws-cli/aws-cli:latest sso login
#   }
  alias aws-login=". ${HOME}/.aws/login"
  alias aws-logout='aws sso logout && unset AWS_PROFILE'
  function aws-list { /usr/bin/grep profile ${HOME}/.aws/config | awk '{print $2}' | cut -d']' -f1 | LANG=C sort; }
fi
