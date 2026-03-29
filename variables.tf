############################################################
# variables.tf - Root input variables 
############################################################

variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "eu-west-2" # London 
}

variable "project_name" {
  description = "Unique short name for the project (used in resource names and tags)."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

# ----- Networking ----------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for pribate subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across."
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnet internet access."
  type        = bool
  default     = true

}
# ----- Security ----------------------------------
variable "create_bastion_sg" {
  description = "Whether to create a bastion host security group."
  type        = bool
  default     = true
}

variable "trusted_ssh_cidr" {
  description = "CIDR allowed to SSH into the bastion. Never use 0.0.0.0/0 in production."
  type        = string
  default     = "0.0.0.0/0"
}

# ----- Compute ----------------------------------
variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB."
  type        = number
  default     = 20
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring (billed per instance)."
  type        = bool
  default     = false
}