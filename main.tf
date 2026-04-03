############################################################
# main.tf - Root configuration 
# Wires together all top-level resources and module calls. 
############################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ----- Networking ----------------------------------
module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway
}

# ----- Security ----------------------------------
module "security" {
  source = "./modules/security"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  create_bastion_sg = var.create_bastion_sg
  trusted_ssh_cidr  = var.trusted_ssh_cidr
}

# ---Compute ----------------------------------------------
module "compute" {
  source = "./modules/compute"

  project_name               = var.project_name
  environment                = var.environment
  security_group_id          = module.security.app_security_group_id
  iam_instance_profile_name  = module.security.ec2_ssm_instance_profile_name
  private_subnet_id          = module.networking.private_subnet_ids[0]
  private_subnet_ids         = module.networking.private_subnet_ids
  instance_type              = var.instance_type
  root_volume_size           = var.root_volume_size
  enable_detailed_monitoring = var.enable_detailed_monitoring
  asg_min_size               = var.asg_min_size
  asg_max_size               = var.asg_max_size
  asg_desired_capacity       = var.asg_desired_capacity
}

# ----- Observability ----------------------------------
module "observability" {
  source = "./modules/observability"

  project_name       = var.project_name
  environment        = var.environment
  log_retention_days = var.log_retention_days
  alarm_email        = var.alarm_email
  asg_name           = module.compute.asg_name
  scaling_cooldown   = var.scaling_cooldown
}