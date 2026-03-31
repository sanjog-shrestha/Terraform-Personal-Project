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

variable "private_subnet_id" {
  description = "ID of the private subnet to place the EC2 instance in (from networking module)."
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

variable "private_subnet_ids" {
  description = "List of private subnet IDs to spread ASG instances across (from networking module)."
  type        = list(string)
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group."
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group."
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group."
  type        = number
  default     = 1
}