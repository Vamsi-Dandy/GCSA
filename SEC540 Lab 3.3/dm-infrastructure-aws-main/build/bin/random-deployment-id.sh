#!/bin/bash
set -e

# generate deployment id if missing
if [[ "" == $(vault kv get -field=deployment_id kv/aws/deployment/metadata || echo "") ]]; then
    echo "Generating deployment id"
    DEPLOYMENT_ID=$(uuidgen | cut -b 25-36 | awk '{print tolower($0)}')
    echo "Storing deployment id in vault: $DEPLOYMENT_ID"
    vault kv put kv/aws/deployment/metadata deployment_id="$DEPLOYMENT_ID"
fi

# pull deployment id from vault
vault kv get -field=deployment_id kv/aws/deployment/metadata >.dm_random
echo "Reading deployment id from vault: $(cat .dm_random)"
