#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
    echo "$0 <REGION> <BUCKET_ID>"
    echo "Called incorrectly"
    exit 1
fi

#Bucket var
REGION="$1"
DEPLOYMENT_ID="$2"

echo ""
echo "Initializing AWS infrastructure..."
echo "AWS Deployment ID: $DEPLOYMENT_ID"

# unique bucket name for the state data
BUCKET_NAME="dm-terraform-state-$DEPLOYMENT_ID"
echo "${BUCKET_NAME}" >.dm_tf_state_bucket

BUCKET_FOUND="$(aws s3api list-buckets --query "Buckets[?Name == \`$BUCKET_NAME\`]" | jq '. | length')"

if [[ 0 == "$BUCKET_FOUND" ]]; then
    echo "AWS Terraform state S3 bucket $BUCKET_NAME does not exist. Creating now..."

    if [[ "us-east-1" == "$REGION" ]]; then
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
    else
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"
    fi

    aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
else
    echo "AWS Terraform state S3 bucket $BUCKET_NAME already exists. Skipping creation."
fi
