#!/bin/bash
set -e

# install docs for future upgrades:
# https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html

# sign in to the cluster
. assets/cluster-login.sh

echo "Installing metrics-server for ${CLUSTER_NAME}"

# install metrics-server
echo "Installing metrics-server..."
kubectl apply -f ./assets/eks/metrics-server-components_v0.6.4.yaml
