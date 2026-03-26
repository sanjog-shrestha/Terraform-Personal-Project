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

# 2. Initialise
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
├── main.tf              # Provider config, required providers, default tags
├── variables.tf         # Input variables (region, project name, environment)
├── outputs.tf           # Root outputs exposed after apply
├── terraform.tfvars     # Default variable values (no secrets)
└── .gitignore           # Excludes state files, .terraform/, secrets
```

---

## Input variables

| Variable       | Type   | Default     | Description                       |
|----------------|--------|-------------|-----------------------------------|
| `aws_region`   | string | `eu-west-2` | AWS region to deploy into         |
| `project_name` | string | —           | Short project name (used in tags) |
| `environment`  | string | `dev`       | One of: `dev`, `staging`, `prod`  |

---

## Outputs

| Output         | Description             |
|----------------|-------------------------|
| `aws_region`   | AWS region in use       |
| `project_name` | Active project name     |
| `environment`  | Active environment name |

---

## Providers

| Provider           | Version  |
|--------------------|----------|
| `hashicorp/aws`    | `~> 5.0` |
| `hashicorp/random` | `~> 3.6` |

---

## Adding modules

Create a subdirectory under `modules/` and reference it from `main.tf`:

```hcl
module "networking" {
  source = "./modules/networking"
  # pass variables here
}
```

---

## Environments

To manage multiple environments, create per-environment variable files:

```
environments/
├── dev.tfvars
├── staging.tfvars
└── prod.tfvars
```

Then apply with:

```bash
terraform apply -var-file=environments/dev.tfvars
```

---

## Notes

- **No secrets** should ever be stored in `terraform.tfvars`. Use environment variables or AWS Secrets Manager.
- **State** is currently local. Remote state (S3 + DynamoDB) will be added in a future phase when team collaboration requires it.
- **Tags** are automatically applied to all AWS resources via `default_tags` in the provider block.
