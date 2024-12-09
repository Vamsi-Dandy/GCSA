#!/bin/bash
export PATH=$PATH:/usr/local/bin
echo "userdata-start - $(date)" >>/root/init.log

# cw logs
yum install -y amazon-cloudwatch-agent jq
mkdir -p /opt/aws/amazon-cloudwatch-agent/bin
cat >/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent.json <<EOL
{
    "agent": {
        "metrics_collection_interval": 10,
        "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
    },
    "logs": {
        "logs_collected": {
            "files": {
            "collect_list": [
                {
                "file_path": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
                "log_group_name": "${bastion_log_group}",
                "timezone": "UTC"
                }
            ]
        }
    },
    "force_flush_interval" : 15
    }
}
EOL

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent.json -s
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status

# configure ssm profile
mkdir -p /home/ssm-user/.aws
chown -R ssm-user:ssm-user /home/ssm-user/.aws
