#!/bin/bash
set -e

# install docs for container insights
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html

# sign in to the cluster
. assets/cluster-login.sh

# container insights vars
FluentBitHttpServer='On'
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
FluentBitReadFromTail='On'

# update configuration values
sed -i -e "s#{{cluster_name}}#${CLUSTER_NAME}#g" \
  -e "s#{{region_name}}#${AWS_DEFAULT_REGION}#g" \
  -e "s#{{http_server_toggle}}#${FluentBitHttpServer}#g" \
  -e "s#{{http_server_port}}#${FluentBitHttpPort}#g" \
  -e "s#{{read_from_head}}#${FluentBitReadFromHead}#g" \
  -e "s#{{read_from_tail}}#${FluentBitReadFromTail}#g" \
  ./assets/eks/eks-container-insights.yaml


# apply fluent bit deployment
kubectl apply -f ./assets/eks/eks-container-insights.yaml
