#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
  echo "$0 <REGION>"
  echo "Called incorrectly"
  exit 1
fi

REGION="$1"
ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)

# Check/enable SecurityHub
if ! aws --region "${REGION}" securityhub describe-hub; then
  echo "Enabling SecurityHub"
  aws --region "${REGION}" securityhub enable-security-hub \
    --no-enable-default-standards \
    --tags '{"BusinessUnit": "Audit"}'
  sleep 45
else
  echo "SecurityHub is Enabled"
fi

## Disable the default-enabled standards sets
if [[ 0 -ne $(aws securityhub get-enabled-standards | jq -r '.StandardsSubscriptions | length') ]]; then
  aws securityhub batch-disable-standards \
    --region "${REGION}" \
    --standards-subscription-arns \
    "arn:aws:securityhub:${REGION}:${ACCOUNT}:subscription/cis-aws-foundations-benchmark/v/1.2.0" \
    "arn:aws:securityhub:${REGION}:${ACCOUNT}:subscription/aws-foundational-security-best-practices/v/1.0.0" ||
    echo "Failed to disable foundation standards in Security Hub"
else
  echo "Basic Security Hub standards disabled"
fi

## Enable findings import for Prowler
SUBSCRIPTIONS=$(aws securityhub list-enabled-products-for-import --region "${REGION}")
if echo "$SUBSCRIPTIONS" | jq -r '.ProductSubscriptions[] | select(.|match("prowler"))' | grep -q 'prowler'; then
  echo "Prowler integration already enabled"
else
  aws securityhub enable-import-findings-for-product \
    --region "${REGION}" \
    --product-arn "arn:aws:securityhub:${REGION}::product/prowler/prowler" ||
    echo "Failed to enable Prowler integration for SecurityHub"
fi

## Enable findings import for CloudCustodian
if echo "$SUBSCRIPTIONS" | jq -r '.ProductSubscriptions[] | select(.|match("cloud-custodian"))' | grep -q 'cloud-custodian'; then
  echo "CloudCustodian integration already enabled"
else
  aws securityhub enable-import-findings-for-product \
    --region "${REGION}" \
    --product-arn "arn:aws:securityhub:${REGION}::product/cloud-custodian/cloud-custodian" ||
    echo "Failed to enable Cloud Custodian integration for SecurityHub"
fi

## Check and enable IAM Access Analyzer
if [[ 0 -eq $(aws accessanalyzer list-analyzers | jq -r '.analyzers | length') ]]; then
  echo "Enabling AWS Access Analyser for ACCOUNT"
  aws accessanalyzer create-analyzer --type ACCOUNT \
    --analyzer-name DM_Access_Analyzer \
    --tags BusinessUnit=Audit
else
  echo "AWS Access Analyzer already enabled:"
  aws accessanalyzer list-analyzers | jq -r '.analyzers[] | [.type, .name] | @tsv'
fi
