#!/bin/bash
set -e

# set vars
RESULTS_DIR=$1
SARIF_RESULTS=$2
JUNIT_RESULTS=$3

# create results dir
mkdir -p "${RESULTS_DIR}"

# run the scan
echo "Starting semgrep scan..."
semgrep --version
#LAB13: Implement scan and process results

if [[ -f ${RESULTS_DIR}/${SARIF_RESULTS} ]]; then
    echo "Semgrep scan summary..."
    RULES=$(jq '.runs[].tool.driver.rules | length' <${RESULTS_DIR}/${SARIF_RESULTS})
    FAILURES=$(jq '.runs[].results | length' <${RESULTS_DIR}/${SARIF_RESULTS})
    echo "Number of rules evaluated: ${RULES}"
    echo "Number of rules failing: ${FAILURES}"
    jq -r '.runs[].results[].ruleId' <${RESULTS_DIR}/${SARIF_RESULTS}
fi
