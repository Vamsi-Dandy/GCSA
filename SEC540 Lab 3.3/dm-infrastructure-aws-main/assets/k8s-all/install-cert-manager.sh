#!/bin/bash
set -e

# sign in to the cluster
. assets/cluster-login.sh

# install cert manager
echo "Cert Manager: Installing on ${CLUSTER_NAME}"
kubectl apply -f ./assets/k8s-all/cert-manager.yaml

# wait for cert-manager webhook to becom ready
# https://cert-manager.io/docs/installation/kubectl/#2-optional-wait-for-cert-manager-webhook-to-be-ready
echo "Cert Manager: Waiting for API to be ready"
cmctl check api --wait=4m

