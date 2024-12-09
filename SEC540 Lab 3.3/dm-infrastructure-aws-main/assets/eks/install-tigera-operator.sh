#!/bin/bash
set -e

# sign in to the cluster
. assets/cluster-login.sh

echo "Installing Tigera Operator using Helm Chart on ${CLUSTER_NAME}..."
helm repo add projectcalico https://docs.tigera.io/calico/charts
helm repo update
helm upgrade --install calico projectcalico/tigera-operator --version v3.24.6 \
  --namespace tigera-operator --create-namespace --wait --timeout 5m15s \
  --values ./assets/eks/tigera-operator-values.yaml
