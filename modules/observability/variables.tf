###############################################################################
# modules/observability/variables.tf
###############################################################################

variable "project_name" {
  description = "Project name — used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)."
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs before automatic deletion."
  type        = number
  default     = 14
}

variable "alarm_email" {
  description = "Email address for alarm notifications. Leave empty to skip subscription."
  type        = string
  default     = ""
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group to attach scaling policies to (from compute module)."
  type        = string
}

variable "scaling_cooldown" {
  description = "Seconds to wait after a scaling action before another can trigger."
  type        = number
  default     = 120
}

variable "cpu_high_threshold" {
  description = "CPU utilisation % that triggers the scale-out alarm."
  type        = number
  default     = 70
}

variable "cpu_low_threshold" {
  description = "CPU utilisation % that triggers the scale-in alarm."
  type        = number
  default     = 20
}