###############################################################################
# modules/networking/variables.tf
###############################################################################

variable "project_name" {
  description = "Project name — used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones to spread subnets across."
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnet internet access."
  type        = bool
  default     = true
}