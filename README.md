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
    └── compute/
        ├── main.tf                    # AMI data source, launch template, EC2 instance
        ├── variables.tf               # Compute input variables
        ├── outputs.tf                 # Launch template ID, version, AMI ID, instance ID
        └── templates/
            └── user_data.sh.tpl       # EC2 first-boot startup script
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
| `root_volume_size`           | number | `20`       | Root EBS volume size in GB                            |
| `enable_detailed_monitoring` | bool   | `false`    | Enable 1-min CloudWatch metrics (billed per instance) |

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
| `instance_id`                   | ID of the EC2 instance                     |
| `instance_private_ip`           | Private IP address of the EC2 instance     |

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
├── Storage      20 GB  gp3  encrypted
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
```
<img width="1907" height="551" alt="image" src="https://github.com/user-attachments/assets/b0412535-dbee-4d1c-bea8-7713e66d72b1" />
<img width="1913" height="812" alt="image" src="https://github.com/user-attachments/assets/34aa6bdf-1644-403b-9898-0dc63a4aa97e" />

---

## Roadmap

| Phase | Status   | Feature            | Description                                       |
|-------|----------|--------------------|---------------------------------------------------|
| 1     | ✅ Done  | Base Provider      | AWS provider, variables, outputs, default tags    |
| 2     | ✅ Done  | Networking         | VPC, subnets, IGW, NAT Gateway, route tables      |
| 3     | ✅ Done  | Security Baseline  | Security groups, IAM role, instance profile       |
| 4a    | ✅ Done  | Launch Template    | AMI data source, versioned template, user data    |
| 4b    | ✅ Done  | EC2 Instance       | Single instance referencing the launch template   |
| 4c    | ⏭ Next  | Auto Scaling Group | ASG using the launch template across both AZs     |
| 5     | Planned  | Observability      | CloudWatch log groups, alarms, SNS topics         |
| 6     | Planned  | Remote State       | S3 + DynamoDB locking for team collaboration      |
| 7     | Planned  | CI/CD              | GitHub Actions pipeline for automated apply       |

---

## Adding future modules

Reference new modules from `main.tf`, passing outputs from existing modules as inputs:

```hcl
module "compute" {
  source                     = "./modules/compute"
  project_name               = var.project_name
  environment                = var.environment
  security_group_id          = module.security.app_security_group_id
  iam_instance_profile_name  = module.security.ec2_ssm_instance_profile_name
  private_subnet_id          = module.networking.private_subnet_ids[0]
  instance_type              = var.instance_type
  root_volume_size           = var.root_volume_size
  enable_detailed_monitoring = var.enable_detailed_monitoring
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
- **EC2 instance** will not be replaced automatically on AMI updates — use `terraform taint module.compute.aws_instance.this` to force a recycle.
