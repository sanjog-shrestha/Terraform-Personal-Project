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
    └── security/
        ├── main.tf                    # Security groups, IAM role, instance profile
        ├── variables.tf               # Security input variables
        └── outputs.tf                 # SG IDs, IAM role ARN, instance profile name
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

| Output                          | Description                                     |
|---------------------------------|-------------------------------------------------|
| `app_security_group_id`         | ID of the application security group            |
| `bastion_security_group_id`     | ID of the bastion security group (null if off)  |
| `ec2_ssm_instance_profile_name` | Instance profile name for EC2 instances         |

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

## Roadmap

| Phase | Status  | Feature           | Description                                     |
|-------|---------|-------------------|-------------------------------------------------|
| 1     | ✅ Done | Base Provider     | AWS provider, variables, outputs, default tags  |
| 2     | ✅ Done | Networking        | VPC, subnets, IGW, NAT Gateway, route tables    |
| 3     | ✅ Done | Security Baseline | Security groups, IAM role, instance profile     |
| 4     | ⏭ Next | Compute           | EC2 instances using SG and profile from Phase 3 |
| 5     | Planned | Observability     | CloudWatch log groups, alarms, SNS topics       |
| 6     | Planned | Remote State      | S3 + DynamoDB locking for team collaboration    |
| 7     | Planned | CI/CD             | GitHub Actions pipeline for automated apply     |

---

## Adding future modules

Reference new modules from `main.tf`, passing outputs from existing modules as inputs:

```hcl
module "compute" {
  source               = "./modules/compute"
  vpc_id               = module.networking.vpc_id
  subnet_ids           = module.networking.private_subnet_ids
  security_group_id    = module.security.app_security_group_id
  iam_instance_profile = module.security.ec2_ssm_instance_profile_name
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
