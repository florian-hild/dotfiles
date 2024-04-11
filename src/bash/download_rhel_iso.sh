#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : 27-02-2024
# Description: Download from redhat.com
#-------------------------------------------------------------------------------

export LANG=C
declare -r __SCRIPT_VERSION__='1.0'

read -p "Enter Red Hat API token: " offline_token
if [[ -z "${offline_token// }" ]]; then
  echo "Error: Variable \"offline_token\" not set."
  exit 1
fi

read -p "Enter Red Hat downloads SHA-256 checksum: " checksum
if [[ -z "${checksum// }" ]]; then
  echo "Error: Variable \"checksum\" not set."
  exit 1
fi

# get an access token
access_token=$(curl https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token -d grant_type=refresh_token -d client_id=rhsm-api -d refresh_token=$offline_token | jq -r '.access_token')

# get the filename and download url
image=$(curl -H "Authorization: Bearer $access_token" "https://api.access.redhat.com/management/v1/images/${checksum}/download")
filename=$(echo ${image} | jq -r .body.filename)
url=$(echo ${image} | jq -r .body.href)

# download the file
set -x
curl ${url} --output ${filename}
set +x

exit

