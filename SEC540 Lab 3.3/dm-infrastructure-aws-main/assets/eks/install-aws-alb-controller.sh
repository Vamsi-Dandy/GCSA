#!/bin/bash
set -e

# install docs for future upgrades:
# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/deploy/installation/

# sign in to the cluster
. assets/cluster-login.sh

DM_EKS_ALB_CONTROLLER_ROLE_ARN=$(vault kv get -field=dm_cluster_alb_controller_role_arn kv/aws/deployment/metadata) || echo ""

echo "Installing EKS ALB controller for ${CLUSTER_NAME} using role ${DM_EKS_ALB_CONTROLLER_ROLE_ARN}..."


# verify cert manager
if [[ "" == "$(kubectl get ns --output=json | jq -r '.items[] | select(.metadata.name=="cert-manager").metadata.uid')" ]]; then
    echo "WARNING: Cert Manager is missing!!  Unexpected Results may occur!"
fi

# install alb controller
echo "Installing EKS ALB controller..."
sed -i -e "s#{EKS_CLUSTER_NAME}#${CLUSTER_NAME}#g" -e "s#{EKS_ALB_CONTROLLER_ROLE_ARN}#${DM_EKS_ALB_CONTROLLER_ROLE_ARN}#g" ./assets/eks/alb-controller-full.yaml
kubectl apply -f ./assets/eks/alb-controller-full.yaml
# give the controller time to become available
kubectl wait pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --for condition=Ready --timeout=6m30s

# install alb controller ingress class
echo "Installing EKS ALB ingress class..."
kubectl apply -f ./assets/eks/alb-controller-ingress-class.yaml

