#!/bin/bash
set +x
set -e

## Confirm the values pulled from VAULT are non-empty / reasonable
echo "CHECKING VAULT CREDENTIALS..."

echo -n "AWS_DEFAULT_REGION - "
echo "${AWS_DEFAULT_REGION}" | grep -qE '[a-z]{2}-[a-z]+-[1-9]'
echo "${AWS_DEFAULT_REGION}" | grep -qv 'pe-earth-0'
echo "${AWS_DEFAULT_REGION}" | grep -qE 'us-east-1|us-east-2|us-west-2|us-west-1|eu-west-1|eu-west-3|ap-northeast-1|ap-southeast-1|ap-southeast-2'
echo "OK"

echo -n "AWS_ACCESS_KEY_ID - "
echo "${AWS_ACCESS_KEY_ID}" | grep -qE '^AKI[A-Za-z0-9\.\/]{17}'
echo "${AWS_ACCESS_KEY_ID}" | grep -qv 'AKIAIOSFODNN7EXAMPLE'
echo "OK"

echo -n "AWS_SECRET_ACCESS_KEY - "
echo "${AWS_SECRET_ACCESS_KEY}" | grep -qE '\S+'
echo "${AWS_SECRET_ACCESS_KEY}" | grep -qv 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'
echo "OK"

echo -n "AWS_ACM_PRIVATE_KEY - "
grep -qE 'BEGIN RSA PRIVATE KEY' <"${AWS_ACM_PRIVATE_KEY}"
echo "OK"

echo -n "AWS_ACM_CERTIFICATE_BODY - "
grep -qE 'BEGIN CERTIFICATE' <"${AWS_ACM_CERTIFICATE_BODY}"
echo "OK"

echo -n "AWS_ACM_CERTIFICATE_CHAIN - "
grep -qE 'BEGIN CERTIFICATE' <"${AWS_ACM_CERTIFICATE_CHAIN}"
echo "OK"

echo -n "AWS_EC2_DEVSECOPS_PUBLIC_KEY - "
grep -qE '^ssh-rsa ' <"${AWS_EC2_DEVSECOPS_PUBLIC_KEY}"
echo "OK"

echo -n "AWS_CLOUDFRONT_PUBLIC_KEY - "
grep -qE 'BEGIN PUBLIC KEY' <"${AWS_CLOUDFRONT_PUBLIC_KEY}"
echo "OK"

echo -n "AWS_CLOUDFRONT_PRIVATE_DER - "
grep -qE '[A-Za-z0-9+/]{4}*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)' <"${AWS_CLOUDFRONT_PRIVATE_DER}"
echo "OK"

echo -n "DEVSECOPS IAM USER - "
aws iam get-user | jq -r '.User.UserName' | grep -qE 'devsecops'
echo "OK"
