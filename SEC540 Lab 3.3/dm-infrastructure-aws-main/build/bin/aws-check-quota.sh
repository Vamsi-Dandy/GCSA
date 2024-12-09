#!/bin/bash
# leave this commented, script fails with it
#set -e

TheRegion=$(aws configure get region)
VCPU_Quota=$(aws service-quotas get-service-quota --service-code ec2 --quota-code L-1216C47A | jq -r '.Quota.Value')
VCPU_InUse=$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[].CpuOptions.CoreCount//"0" ' | awk '{s+=$1}END{print s}')
printf "vCPU Check\n  Quota:  %4d\n  Need:     10\n  InUse:  %4d\n" "${VCPU_Quota}" "${VCPU_InUse}"

AVAIL_VCPU=$((${VCPU_Quota} - ${VCPU_InUse}))
if [ 10 -gt ${AVAIL_VCPU} ]; then
  printf "  Avail:  %4d - FAIL\n" "${AVAIL_VCPU}"
  echo "  Insufficient vCPU Quota remaining! Need at least 10 vCPUs."
  echo "  Visit https://${TheRegion}.console.aws.amazon.com/servicequotas/home/services/ec2/quotas/L-1216C47A to requet an increase"
  exit 2
else
  printf "  Avail:  %4d - PASS\n" "${AVAIL_VCPU}"
fi

echo ""

VPC_Data=$(aws ec2 describe-vpcs)
VPC_InUse=$(echo $VPC_Data | jq -r '.Vpcs | length')
VPC_Course=$(echo $VPC_Data | jq -r '.Vpcs[] | (try (.Tags[]|select(.Key=="Name") | select(.Value | contains("dm-"))) catch "unrelated")' | grep -c "dm-")
VPC_Quota=$(aws service-quotas get-service-quota --service-code vpc --quota-code L-F678F1CE | jq -r '.Quota.Value')
printf "VPC Check\n  Quota:  %4d\n  Need:      3\n  InUse:  %4d\n  Course: %4d\n" "${VPC_Quota}" "${VPC_InUse}" "${VPC_Course}"

AVAIL_VPCS=$((${VPC_Quota} - ${VPC_InUse}))
TEST_VPCS=$((${VPC_Quota} - ${VPC_InUse} + ${VPC_Course}))
if [ 3 -gt ${TEST_VPCS} ]; then
  printf "  Avail:  %4d - FAIL\n" "${AVAIL_VPCS}"
  echo "  Insufficient VPC Quota remaining! Need at least 3 VPCs available."
  echo "  Visit https://${TheRegion}.console.aws.amazon.com/servicequotas/home/services/vpc/quotas/L-F678F1CE to request an increase"
  exit 3
else
  printf "  Avail:  %4d - PASS\n" "${AVAIL_VPCS}"
fi

echo ""
