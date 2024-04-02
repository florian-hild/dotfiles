# Terraform

if command -v terraform > /dev/null 2>&1; then
  alias tfi='terraform init'
  alias tfp='time terraform plan'
  alias tfa='time terraform apply'
  alias twl='terraform workspace list '
  alias tws='terraform workspace select '
  alias twn='terraform workspace new '
  alias tfoj='terraform output --json '
fi
