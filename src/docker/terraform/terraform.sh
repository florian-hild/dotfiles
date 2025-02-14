#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Author     : Florian Hild
# Created    : dd-mm-yyyy
# Description:
#-------------------------------------------------------------------------------

export LANG=C
declare -r __SCRIPT_VERSION__='1.0'

docker run --rm \
           --init \
           --env TZ='Europe/Berlin' \
           --volume $(pwd)/../../modules:/workspace/modules:rw \
           --volume $(pwd):/workspace/tf/environment:rw \
           hashicorp/terraform:1.10.5 -chdir=/workspace/tf/environment "${@}"

