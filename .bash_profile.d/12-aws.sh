# shellcheck disable=SC2148
# AWS cli setup

# cat ~/.aws/login
#

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
  function aws-list { /usr/bin/grep profile "${HOME}"/.aws/config | awk '{print $2}' | cut -d']' -f1 | LANG=C sort; }
  function aws-login {
    if [[ -z "${1}" ]]; then
      grep '^\[profile' "${HOME}/.aws/config" | sed 's/[][]//g; s/profile //' | LANG=C sort
    else
      export AWS_PROFILE="${1}"
      aws sso login --profile "${1}"
      if command -v op > /dev/null 2>&1; then
        export OP_SERVICE_ACCOUNT_TOKEN=$(op item get vpgd6jtqm5kteh3se6jweergvu --reveal --fields label=Anmeldedaten)
      else
        echo "op command not found; OP_SERVICE_ACCOUNT_TOKEN not set" >&2
      fi
    fi
  }
  alias aws-logout='aws sso logout && unset AWS_PROFILE'
fi
