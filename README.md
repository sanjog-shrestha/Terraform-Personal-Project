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
├── main.tf                        # Provider config, module calls
├── variables.tf                   # Root input variables
├── outputs.tf                     # Root outputs
├── terraform.tfvars               # Default variable values (no secrets)
├── .gitignore                     # Excludes state files, .terraform/, secrets
└── modules/
    └── networking/
        ├── main.tf                # VPC, subnets, IGW, NAT Gateway, route tables
        ├── variables.tf           # Networking input variables
        └── outputs.tf             # Networking outputs (VPC ID, subnet IDs, etc.)
```

---

## Input variables

### Root

| Variable              | Type         | Default                              | Description                          |
|-----------------------|--------------|--------------------------------------|--------------------------------------|
| `aws_region`          | string       | `eu-west-2`                          | AWS region to deploy into            |
| `project_name`        | string       | —                                    | Short project name (used in tags)    |
| `environment`         | string       | `dev`                                | One of: `dev`, `staging`, `prod`     |
| `vpc_cidr`            | string       | `10.0.0.0/16`                        | CIDR block for the VPC               |
| `public_subnet_cidrs` | list(string) | `["10.0.1.0/24","10.0.2.0/24"]`      | Public subnet CIDRs (one per AZ)     |
| `private_subnet_cidrs`| list(string) | `["10.0.101.0/24","10.0.102.0/24"]`  | Private subnet CIDRs (one per AZ)    |
| `availability_zones`  | list(string) | `["eu-west-2a","eu-west-2b"]`        | AZs to spread subnets across         |
| `enable_nat_gateway`  | bool         | `true`                               | Create a NAT Gateway for private AZs |

---

## Outputs

| Output               | Description                              |
|----------------------|------------------------------------------|
| `aws_region`         | AWS region in use                        |
| `project_name`       | Active project name                      |
| `environment`        | Active environment                       |
| `vpc_id`             | ID of the created VPC                    |
| `public_subnet_ids`  | List of public subnet IDs                |
| `private_subnet_ids` | List of private subnet IDs               |
| `nat_gateway_id`     | ID of the NAT Gateway (null if disabled) |

---

## Providers

| Provider           | Version  |
|--------------------|----------|
| `hashicorp/aws`    | `~> 5.0` |
| `hashicorp/random` | `~> 3.6` |

---

## Networking architecture

```
VPC (10.0.0.0/16)
├── Public Subnet AZ-a  (10.0.1.0/24)   → Internet Gateway → Internet
├── Public Subnet AZ-b  (10.0.2.0/24)   → Internet Gateway → Internet
├── Private Subnet AZ-a (10.0.101.0/24) → NAT Gateway → Internet
└── Private Subnet AZ-b (10.0.102.0/24) → NAT Gateway → Internet
```

---

## Adding future modules

Reference new modules from `main.tf`, passing networking outputs as inputs:

```hcl
module "security" {
  source   = "./modules/security"
  vpc_id   = module.networking.vpc_id
  # ...
}
```

---

## Notes

- **No secrets** should ever be stored in `terraform.tfvars`. Use environment variables or AWS Secrets Manager.
- **State** is currently local. Remote state (S3 + DynamoDB) will be added in a future phase.
- **Tags** are automatically applied to all AWS resources via `default_tags` in the provider block.
- **NAT Gateway** incurs AWS charges even when idle. Set `enable_nat_gateway = false` to disable in cost-sensitive environments.
