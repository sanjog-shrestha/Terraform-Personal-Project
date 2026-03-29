#!/bin/bash
# user_data.sh.tpl
# Runs once on first boot for every instance launched from this template.

set -euo pipefail

dnf update -y 

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent 

hostnamectl set-hostname "{project_name}-${environment}"

echo "Instance booted: $${date}" >> /var/log/bootstrap.log
echo "Project: ${project_name}" >> /var/log/bootstrap.log
echo "Environment: ${environment}" >> /var/log/bootstrap.log