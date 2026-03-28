###############################################################################
# modules/security/variables.tf
###############################################################################

variable "project_name" {
  description = "Project name — used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to create security groups in."
  type        = string
}

variable "create_bastion_sg" {
  description = "Whether to create a bastion host security group."
  type        = bool
  default     = true
}

variable "trusted_ssh_cidr" {
  description = "CIDR block allowed to SSH into the bastion. Never use 0.0.0.0/0 in production."
  type        = string
  default     = "0.0.0.0/0"
}