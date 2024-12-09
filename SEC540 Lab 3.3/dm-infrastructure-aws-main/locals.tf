locals {
  network_addresses = {
    dev = {
      vpc_cidr_block      = "10.101.0.0/16"
      subnet_private_a    = "10.101.128.0/20"
      subnet_private_b    = "10.101.144.0/20"
      subnet_public_a     = "10.101.2.0/25"
      subnet_public_b     = "10.101.2.128/25"
      subnet_management_a = "10.101.255.0/25"
      subnet_management_b = "10.101.255.128/25"
    }
    stage = {
      vpc_cidr_block      = "10.102.0.0/16"
      subnet_private_a    = "10.102.128.0/20"
      subnet_private_b    = "10.102.144.0/20"
      subnet_public_a     = "10.102.2.0/25"
      subnet_public_b     = "10.102.2.128/25"
      subnet_management_a = "10.102.255.0/25"
      subnet_management_b = "10.102.255.128/25"
    }
    prod = {
      vpc_cidr_block      = "10.103.0.0/16"
      subnet_private_a    = "10.103.128.0/20"
      subnet_private_b    = "10.103.144.0/20"
      subnet_public_a     = "10.103.2.0/25"
      subnet_public_b     = "10.103.2.128/25"
      subnet_management_a = "10.103.255.0/25"
      subnet_management_b = "10.103.255.128/25"
    }
  }

  # Viable availability zones
  az_blue = random_shuffle.az.result[0]
  az_cyan = random_shuffle.az.result[1]

  tags = {
    Owner       = var.tag_owner
    CostCenter  = var.tag_cost_center
    Environment = var.env
  }

  dm_cloudtrail_name  = "dm-cloudtrail-${var.env}"
  dm_eks_cluster_name = "dm-app"

  # Description: 'Options to pass to Prowler command, make sure at least -M junit-xml is used for CodeBuild reports.
  # Prowler Options:
  # -M <output modes> - comma separated list of output formats
  # -c <checks list> - comma separated list of checks
  # -g <check group> - single group identifier
  # -S - send json-asff output to Security Hub
  # -q - only send FAILUREs, skip WARNINGs
  dm_prowler_checks  = "check11,check13,check14,check41,check42,extra741,extra742,extra759,extra760,extra768,extra775,extra7129,extra7141"
  dm_prowler_options = "-M text,junit-xml,html,csv,json,json-asff -c ${local.dm_prowler_checks}"
  # The time when Prowler will run in cron format. Default is daily at 22:00h or 10PM 'cron(0 22 * * ? *)', for every 5 hours also works 'rate(5 hours)'. More info here https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
  dm_prowler_schedule = "cron(0 22 * * ? *)"
  dm_prowler_version  = "2.7.0"

  waf_http_flood_request_threshold         = 250
  waf_scanners_probe_bad_request_threshold = 100
  waf_scanners_probe_block_minutes         = 240
}
