#!/bin/bash
set -e

# sign in to the cluster
CLUSTER_NAME=$(vault kv get -field=eks_name kv/aws/deployment/metadata) || echo ""
aws eks update-kubeconfig --name "${CLUSTER_NAME}"

export CLUSTER_NAME
echo -n "Authenticated at "; date +"%FT%T.%N"
