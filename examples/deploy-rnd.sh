#!/bin/bash

BASE_DIR=$(dirname "$(realpath "$0")") #"
deployment_name=redis-rnd

bosh -d ${deployment_name} deploy "$BASE_DIR/manifests/redis-ha.yml" \
  -v deployment_name="${deployment_name}" \
  -o "$BASE_DIR/manifests/ops/additional-users.yml" \
  --vars-file="$BASE_DIR/vars/${deployment_name}-vars.yml" \
  --no-redact --fix

