###############################################################################
# modules/compute/variables.tf
###############################################################################

variable "project_name" {
  description = "Project name — used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)."
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group to attach to instances (from security module)."
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile to attach to instances (from security module)."
  type        = string
}

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