#!/bin/bash
set -e

# set vars
TARGET_URL=$1
RESULTS_DIR=$2
JUNIT_RESULTS=$3
ZAP_PORT='54088'
ZAP_API_KEY='monkeyflips'

mkdir -p "${RESULTS_DIR}"
mkdir -p /zap/wrk/
cd /zap/wrk

echo -n 'TARGET: '
echo ${TARGET_URL}
curl -skIG ${TARGET_URL} | tee -a /zap/wrk/dm-web-target_check.log

echo "Starting scan"
return_code=0
{ /zap/zap-baseline.py -t ${TARGET_URL} \
  -J dm-web.json -w dm-web.md -x dm-web.xml -r dm-web.html \
  -z "-dir /zap/wrk -installdir /zap -config api.key=${ZAP_API_KEY} port=${ZAP_PORT}" \
  -T 1 -m 2 -I -g gen-aws.conf || return_code=$?
} | tee -a /zap/wrk/dm-web-scan.log

echo "Got return code $return_code"

echo "Displaying files"
pwd
ls

echo "Converting to JUnit"
python3 /zap/zap-json-to-junit.py dm-web.json > ${CI_PROJECT_DIR}/${RESULTS_DIR}/${JUNIT_RESULTS} || echo "Result: $?"
echo "Finished"

exit $return_code