#!/bin/bash
set -e

# sign in to the cluster
. assets/cluster-login.sh

echo "Cosign Policy Controller: helm install on ${CLUSTER_NAME}..."
helm repo add sigstore https://sigstore.github.io/helm-charts || true
helm repo update
helm upgrade --install policy-controller sigstore/policy-controller --version 0.6.3 \
  --namespace cosign-system --create-namespace --wait --timeout "5m31s" \
  --set-json webhook.configData='{"no-match-policy": "warn"}'
