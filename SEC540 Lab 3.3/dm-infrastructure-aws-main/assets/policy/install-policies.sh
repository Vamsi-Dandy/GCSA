#!/bin/bash
set -e

# sign in to the cluster
. assets/cluster-login.sh

# install OPA Gatekeeper Policies
echo "OPA Gatekeeper Policies: Installing Templates on ${CLUSTER_NAME}..."
kubectl apply -k https://gitlab.sans.labs/external/gatekeeper-library//library/general

echo "OPA Gatekeeper Policies: Installing Constratints on ${CLUSTER_NAME}..."
kubectl apply -f ./assets/policy/opa-repo-constraint.yaml

## install Cosign Policies
echo "Cosign: Installing Cluster Image Policies on ${CLUSTER_NAME}..."
kubectl apply -f ./assets/policy/cosign-cluster-image-policy.yaml

# echo "Cosign: Enabling Cluster Image Policies on ${CLUSTER_NAME} in 'dm' namespace ..."
# kubectl get ns -l policy.sigstore.dev/include=true -o name | grep -q 'namespace/dm' \
#   || kubectl label --overwrite ns dm policy.sigstore.dev/include=true
