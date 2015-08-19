#!/bin/sh

set -e
set -x

# Install /etc/my_init.d/00_OA_vars.sh
curl https://raw.githubusercontent.com/OpenAperture/utils/master/oa_envver/00_OA_Vars.sh -o /etc/my_init.d/00_OA_vars.sh
chmod 755 /etc/my_init.d/00_OA_vars.sh

# Install envver
mkdir -p /opt/bin
curl https://s3.amazonaws.com/lexmark-devops-artifacts/binaries/envver-linux-amd64 -o /opt/bin/envver-linux-amd64
chmod 755 /opt/bin /opt/bin/*
