#!/bin/bash
set -e

# sign in to the cluster
. assets/cluster-login.sh

# install OPA Gatekeeper
echo "OPA Gatekeeper: Installing on ${CLUSTER_NAME}..."
kubectl apply --wait -f ./assets/k8s-all/opa-gatekeeper.yaml
# wait for the controller to become Ready
kubectl wait pods -n gatekeeper-system -l gatekeeper.sh/operation=webhook --for condition=Ready --timeout=90s


# install docs for future upgrades:
# https://open-policy-agent.github.io/gatekeeper/website/docs/install
# wget https://raw.githubusercontent.com/open-policy-agent/gatekeeper/<TAG>/deploy/gatekeeper.yaml
# cat gatekeeper.yaml | sed -e 's#replicas: 3#replicas: 2#g' > opa-gatekeeper.yaml
# rm gatekeeper.yaml
