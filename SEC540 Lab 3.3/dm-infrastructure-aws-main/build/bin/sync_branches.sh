#!/bin/bash

export GIT_MERGE_AUTOEDIT=no

sync_branches() {
  CURRENT_BRANCH="$1"
  ORDERED_BRANCHES=(main security/gold-image security/container-scanning feature/eks-workload-identity feature/admission-control feature/container-insights feature/cloudfront-signing feature/api-gateway security/serverless-review feature/security-hub security/enable-waf feature/cloud-custodian)

  for i in "${!ORDERED_BRANCHES[@]}"; do
    THIS_BRANCH="${ORDERED_BRANCHES[$i]}"
    NEXT_BRANCH="${ORDERED_BRANCHES[$i + 1]}"

    if [[ "$CURRENT_BRANCH" == "$THIS_BRANCH" ]]; then
      break
    fi
  done

  if [[ ! -z "$NEXT_BRANCH" ]]; then
    echo "Merging $CURRENT_BRANCH into $NEXT_BRANCH"
    git checkout -B "$NEXT_BRANCH"
    git pull origin "$NEXT_BRANCH"
    git merge "$CURRENT_BRANCH"
    git push --set-upstream origin "$NEXT_BRANCH"
    sync_branches "$NEXT_BRANCH"
  fi
}

ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git pull
git push --set-upstream origin "$ORIGINAL_BRANCH"
sync_branches "$ORIGINAL_BRANCH"
git checkout "$ORIGINAL_BRANCH"
