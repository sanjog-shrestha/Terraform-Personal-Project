# terraform-aws

Base Terraform project for AWS infrastructure (Amazon Web Services).  
Region: `eu-west-2` (London) — configurable via `terraform.tfvars`.

---

## Prerequisites

| Tool      | Min version |
|-----------|-------------|
| Terraform | 1.6.0       |
| AWS CLI   | 2.x         |

---

## Quick start

```bash
# 1. Authenticate to AWS
aws configure   # or export AWS_PROFILE=<your-profile>

# 2. Initialise (downloads providers and modules)
terraform init

# 3. Review plan
terraform plan -var-file=terraform.tfvars

# 4. Apply
terraform apply -var-file=terraform.tfvars
```

---

## Directory structure

```
terraform-aws/
├── main.tf                            # Provider config, module calls
├── variables.tf                       # Root input variables
├── outputs.tf                         # Root outputs
├── terraform.tfvars                   # Default variable values (no secrets)
├── .gitignore                         # Excludes state files, .terraform/, secrets
└── modules/
    ├── networking/
    │   ├── main.tf                    # VPC, subnets, IGW, NAT Gateway, route tables
    │   ├── variables.tf               # Networking input variables
    │   └── outputs.tf                 # VPC ID, subnet IDs, IGW ID, NAT GW ID
    ├── security/
    │   ├── main.tf                    # Security groups, IAM role, instance profile
    │   ├── variables.tf               # Security input variables
    │   └── outputs.tf                 # SG IDs, IAM role ARN, instance profile name
    ├── compute/
    │   ├── main.tf                    # AMI data source, launch template, EC2 instance, ASG
    │   ├── variables.tf               # Compute input variables
    │   ├── outputs.tf                 # Launch template ID, instance ID, ASG name/ARN
    │   └── templates/
    │       └── user_data.sh.tpl       # EC2 first-boot startup script
    └── observability/
        ├── main.tf                    # Log group, SNS topic, ASG scaling policies, CPU alarms
        ├── variables.tf               # Observability input variables
        └── outputs.tf                 # Log group, SNS topic, scaling policy and alarm ARNs
```

---

## Input variables

### General

| Variable       | Type   | Default     | Description                       |
|----------------|--------|-------------|-----------------------------------|
| `aws_region`   | string | `eu-west-2` | AWS region to deploy into         |
| `project_name` | string | —           | Short project name (used in tags) |
| `environment`  | string | `dev`       | One of: `dev`, `staging`, `prod`  |

### Networking

| Variable               | Type         | Default                               | Description                          |
|------------------------|--------------|---------------------------------------|--------------------------------------|
| `vpc_cidr`             | string       | `10.0.0.0/16`                         | CIDR block for the VPC               |
| `public_subnet_cidrs`  | list(string) | `["10.0.1.0/24", "10.0.2.0/24"]`     | Public subnet CIDRs (one per AZ)     |
| `private_subnet_cidrs` | list(string) | `["10.0.101.0/24", "10.0.102.0/24"]` | Private subnet CIDRs (one per AZ)    |
| `availability_zones`   | list(string) | `["eu-west-2a", "eu-west-2b"]`       | AZs to spread subnets across         |
| `enable_nat_gateway`   | bool         | `true`                                | Create a NAT Gateway for private AZs |

### Security

| Variable            | Type   | Default     | Description                                       |
|---------------------|--------|-------------|---------------------------------------------------|
| `create_bastion_sg` | bool   | `true`      | Create a bastion host security group              |
| `trusted_ssh_cidr`  | string | `0.0.0.0/0` | CIDR allowed SSH access. Restrict in production!  |

### Compute

| Variable                     | Type   | Default    | Description                                           |
|------------------------------|--------|------------|-------------------------------------------------------|
| `instance_type`              | string | `t3.micro` | EC2 instance type                                     |
| `root_volume_size`           | number | `30`       | Root EBS volume size in GB (min 30 for AL2023)        |
| `enable_detailed_monitoring` | bool   | `false`    | Enable 1-min CloudWatch metrics (billed per instance) |
| `asg_min_size`               | number | `1`        | Minimum number of instances in the ASG                |
| `asg_max_size`               | number | `3`        | Maximum number of instances in the ASG                |
| `asg_desired_capacity`       | number | `1`        | Desired number of instances in the ASG                |

### Observability

| Variable             | Type   | Default | Description                                              |
|----------------------|--------|---------|----------------------------------------------------------|
| `log_retention_days`   | number | `14`  | Days to retain CloudWatch logs before automatic deletion |
| `alarm_email`          | string | `""`  | Email for alarm notifications. Leave empty to skip       |
| `scaling_cooldown`     | number | `120` | Seconds between scaling actions to prevent oscillation   |
| `cpu_high_threshold`   | number | `70`  | CPU % above which the scale-out alarm fires              |
| `cpu_low_threshold`    | number | `20`  | CPU % below which the scale-in alarm fires               |

---

## Outputs

### General

| Output         | Description         |
|----------------|---------------------|
| `aws_region`   | AWS region in use   |
| `project_name` | Active project name |
| `environment`  | Active environment  |

### Networking

| Output               | Description                              |
|----------------------|------------------------------------------|
| `vpc_id`             | ID of the created VPC                    |
| `public_subnet_ids`  | List of public subnet IDs                |
| `private_subnet_ids` | List of private subnet IDs               |
| `nat_gateway_id`     | ID of the NAT Gateway (null if disabled) |

### Security

| Output                          | Description                                    |
|---------------------------------|------------------------------------------------|
| `app_security_group_id`         | ID of the application security group           |
| `bastion_security_group_id`     | ID of the bastion security group (null if off) |
| `ec2_ssm_instance_profile_name` | Instance profile name for EC2 instances        |

### Compute

| Output                          | Description                                |
|---------------------------------|--------------------------------------------|
| `launch_template_id`            | ID of the launch template                  |
| `launch_template_latest_version`| Latest version number of the template      |
| `ami_id`                        | Resolved AMI ID (latest Amazon Linux 2023) |
| `instance_id`                   | ID of the standalone EC2 instance          |
| `instance_private_ip`           | Private IP of the standalone EC2 instance  |
| `asg_name`                      | Name of the Auto Scaling Group             |
| `asg_arn`                       | ARN of the Auto Scaling Group              |

### Observability

| Output                  | Description                                          |
|-------------------------|------------------------------------------------------|
| `log_group_name`        | Name of the CloudWatch log group                     |
| `log_group_arn`         | ARN of the CloudWatch log group                      |
| `sns_topic_arn`         | ARN of the SNS alarm topic                           |
| `scale_out_policy_arn`  | ARN of the scale-out policy (used by CPU high alarm) |
| `scale_in_policy_arn`   | ARN of the scale-in policy (used by CPU low alarm)   |
| `cpu_high_alarm_arn`    | ARN of the CPU high CloudWatch alarm                 |
| `cpu_low_alarm_arn`     | ARN of the CPU low CloudWatch alarm                  |

---

## Providers

| Provider           | Version  |
|--------------------|----------|
| `hashicorp/aws`    | `~> 5.0` |
| `hashicorp/random` | `~> 3.6` |

---

## Networking architecture

```
VPC  10.0.0.0/16
│
├── Public Subnet 1   10.0.1.0/24    eu-west-2a ──► Internet Gateway ──► Internet
├── Public Subnet 2   10.0.2.0/24    eu-west-2b ──► Internet Gateway ──► Internet
│                                                ▲
│                               NAT Gateway placed in Public Subnet 1
│
├── Private Subnet 1  10.0.101.0/24  eu-west-2a ──► NAT Gateway ──► Internet (outbound only)
└── Private Subnet 2  10.0.102.0/24  eu-west-2b ──► NAT Gateway ──► Internet (outbound only)
```
<img width="1666" height="427" alt="image" src="https://github.com/user-attachments/assets/137e3953-c30c-4751-a36c-b78b9f22e20f" />

---

## Security architecture

```
VPC
│
├── Default Security Group ──── No rules (locked down)
│
├── App Security Group
│   ├── Inbound:  TCP 80  from 0.0.0.0/0  (HTTP)
│   ├── Inbound:  TCP 443 from 0.0.0.0/0  (HTTPS)
│   └── Outbound: All     to  0.0.0.0/0
│
├── Bastion Security Group (optional)
│   ├── Inbound:  TCP 22 from trusted_ssh_cidr
│   └── Outbound: All    to  0.0.0.0/0
│
└── IAM
    ├── Role:             ec2-ssm-role  (trust: ec2.amazonaws.com)
    │   └── Policy:       AmazonSSMManagedInstanceCore
    └── Instance Profile: ec2-ssm-profile
```
<img width="1736" height="175" alt="image" src="https://github.com/user-attachments/assets/a8c97915-fe53-4a30-a824-488a865cd72a" />

<img width="1590" height="658" alt="image" src="https://github.com/user-attachments/assets/341ceb1d-b936-4b3c-b108-40475786a3fd" />

---

## Compute architecture

```
Launch Template  (my-project-dev-lt)
│
├── AMI          Amazon Linux 2023 (latest, resolved automatically)
├── Instance     t3.micro
├── Storage      30 GB  gp3  encrypted  (min 30 GB required by AL2023 AMI)
├── IAM          ec2-ssm-profile  (SSM Session Manager access)
├── Security     app-sg  (HTTP 80, HTTPS 443)
├── Metadata     IMDSv2 enforced  (http_tokens = required)
├── Monitoring   Detailed monitoring off by default
└── User Data    user_data.sh.tpl
                 ├── dnf update -y
                 ├── systemctl start amazon-ssm-agent
                 └── hostnamectl set-hostname {project}-{env}

EC2 Instance  (my-project-dev-instance)
├── Subnet       Private Subnet 1  (10.0.101.0/24  eu-west-2a)
├── Template     my-project-dev-lt  @ latest version
└── Access       SSM Session Manager only — no public IP, no port 22

Auto Scaling Group  (my-project-dev-asg)
├── Subnets      Private Subnet 1 (eu-west-2a) + Private Subnet 2 (eu-west-2b)
├── Capacity     Min: 1  /  Desired: 1  /  Max: 3
├── Health       EC2 health checks  (grace period: 120s)
├── Refresh      Rolling strategy  (50% min healthy)
└── Template     my-project-dev-lt  @ latest version
```
<img width="1907" height="551" alt="image" src="https://github.com/user-attachments/assets/b0412535-dbee-4d1c-bea8-7713e66d72b1" />
<img width="1913" height="812" alt="image" src="https://github.com/user-attachments/assets/34aa6bdf-1644-403b-9898-0dc63a4aa97e" />
<img width="1908" height="785" alt="image" src="https://github.com/user-attachments/assets/1d41f693-481b-4057-9eb6-de6285a2e27f" />

---

## Observability architecture

```
CloudWatch Log Group  (/my-project/dev/app)
├── Retention    14 days (configurable via log_retention_days)
└── Purpose      Central log destination for all application instances

SNS Topic  (my-project-dev-alarms)
├── Purpose      Single notification channel for all CloudWatch alarms
└── Subscribers  Email (optional — set alarm_email to activate)
                 └── Status: PendingConfirmation until email link clicked

ASG Scaling Policies
├── scale-out    +1 instance  |  cooldown: 120s  |  triggered by CPU high alarm
└── scale-in     -1 instance  |  cooldown: 120s  |  triggered by CPU low alarm

CloudWatch CPU Alarms
├── cpu-high     CPU > 70% for 4 min  ──► SNS notification + scale-out policy
│                                         ok_actions: SNS recovery notification
└── cpu-low      CPU < 20% for 4 min  ──► SNS notification + scale-in policy
                                          ok_actions: SNS recovery notification
```
<img width="1912" height="512" alt="image" src="https://github.com/user-attachments/assets/8294b88e-0662-488a-9625-8fd4839ff400" />
<img width="1810" height="537" alt="image" src="https://github.com/user-attachments/assets/e5320bfc-7b42-4d22-bae0-5856fe27d16f" />
<img width="1747" height="465" alt="image" src="https://github.com/user-attachments/assets/8d2fd17d-7512-4723-a6ed-fe429b99100f" />


---

## Roadmap

| Phase | Status   | Feature                    | Description                                        |
|-------|----------|----------------------------|----------------------------------------------------|
| 1     | ✅ Done  | Base Provider              | AWS provider, variables, outputs, default tags     |
| 2     | ✅ Done  | Networking                 | VPC, subnets, IGW, NAT Gateway, route tables       |
| 3     | ✅ Done  | Security Baseline          | Security groups, IAM role, instance profile        |
| 4a    | ✅ Done  | Launch Template            | AMI data source, versioned template, user data     |
| 4b    | ✅ Done  | EC2 Instance               | Single instance referencing the launch template    |
| 4c    | ✅ Done  | Auto Scaling Group         | Multi-AZ ASG with rolling instance refresh         |
| 5a    | ✅ Done  | CloudWatch Log Group       | Retained, named log destination for app logs       |
| 5b    | ✅ Done  | SNS Topic + Subscription   | Notification channel for all alarms                |
| 5c    | ✅ Done  | ASG Scaling Policies       | Scale-out and scale-in policies                    |
| 5d    | ✅ Done  | CloudWatch CPU Alarms      | CPU high/low alarms wired to policies and SNS      |
| 6     | ⏭ Next  | Remote State               | S3 + DynamoDB locking for team collaboration       |
| 7     | Planned  | CI/CD                      | GitHub Actions pipeline for automated apply        |

---

## Adding future modules

Reference new modules from `main.tf`, passing outputs from existing modules as inputs:

```hcl
module "observability" {
  source = "./modules/observability"

  project_name       = var.project_name
  environment        = var.environment
  log_retention_days = var.log_retention_days
  alarm_email        = var.alarm_email
  asg_name           = module.compute.asg_name
  scaling_cooldown   = var.scaling_cooldown
  cpu_high_threshold = var.cpu_high_threshold
  cpu_low_threshold  = var.cpu_low_threshold
}
```

---

## Notes

- **No secrets** should ever be stored in `terraform.tfvars`. Use environment variables or AWS Secrets Manager.
- **State** is currently local. Remote state (S3 + DynamoDB) will be added in Phase 6.
- **Tags** are automatically applied to all AWS resources via `default_tags` in the provider block.
- **NAT Gateway** incurs AWS charges even when idle. Set `enable_nat_gateway = false` to disable in cost-sensitive environments.
- **trusted_ssh_cidr** defaults to `0.0.0.0/0` for development. Always restrict to a specific IP or CIDR before deploying to production.
- **SSM Session Manager** is pre-configured via the EC2 IAM role — no SSH keys or open port 22 required for instance access.
- **IMDSv2** is enforced on all instances via the launch template metadata options, blocking SSRF-based credential theft.
- **AMI** is resolved automatically at plan time — always the latest Amazon Linux 2023 x86_64 HVM image, no manual updates needed.
- **root_volume_size** minimum is 30 GB — the AL2023 AMI snapshot requires at least 30 GB; values below this will cause `terraform apply` to fail.
- **EC2 instance** will not be replaced automatically on AMI updates — use `terraform taint module.compute.aws_instance.this` to force a recycle.
- **ASG instance refresh** handles rolling updates when the launch template changes — no manual instance replacement needed.
- **ASG desired capacity** is managed dynamically by AWS via the CloudWatch CPU alarms — scale-out fires above 70% CPU, scale-in fires below 20%.
- **CloudWatch log retention** defaults to 14 days. Without a retention policy, logs accumulate indefinitely — always set this explicitly.
- **SNS email subscription** requires confirmation — AWS sends a confirmation email after `terraform apply`. No notifications are delivered until the link is clicked.
- **scaling_cooldown** defaults to 120 seconds — prevents rapid oscillation between scale-out and scale-in during transient CPU spikes.
- **cpu_high_threshold** defaults to 70% — CPU must exceed this for 4 consecutive minutes (2 × 2-min periods) before scale-out fires.
- **cpu_low_threshold** defaults to 20% — the 50-point gap between high and low thresholds creates a hysteresis band that prevents continuous scale-out/scale-in oscillation.
