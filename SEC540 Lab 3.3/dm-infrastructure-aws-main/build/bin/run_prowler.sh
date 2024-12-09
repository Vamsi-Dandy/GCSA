#!/bin/bash
set -e

## Trigger immediate run of prowler
PROWLER_BUILD=$(aws codebuild list-projects | jq -r '.projects[] | select(.|test("dm-audit-prowler-codebuild"))')
aws codebuild start-build --project-name "${PROWLER_BUILD}" |
  jq -r '.build | [.buildStatus, .buildNumber, .currentPhase, .id] | @tsv'
